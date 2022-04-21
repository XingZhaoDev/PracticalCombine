//
//  ViewController.swift
//  PracticalCombine
//
//  Created by Xing Zhao on 2022-04-21.
//

import UIKit
import Combine

extension Publisher where Output == String, Failure == Never {
    func toURLSessionDataTaskBeta(baseURL: URL) -> AnyPublisher<URLSession.DataTaskPublisher.Output, URLError> {
        if #available(iOS 14, *) {
            return self
                .flatMap { path -> URLSession.DataTaskPublisher in
                    let url = baseURL.appendingPathComponent(path)
                    return URLSession.shared.dataTaskPublisher(for: url)
                }
                .eraseToAnyPublisher()
        } else {
            return self
                .setFailureType(to: URLError.self)
                .flatMap { path -> URLSession.DataTaskPublisher in
                    let url = baseURL.appendingPathComponent(path)
                    return URLSession.shared.dataTaskPublisher(for: url)
                }
                .eraseToAnyPublisher()
        }
    }
}

class ViewController: UIViewController {
    var cancellables = Set<AnyCancellable>()
    var carViewModel = CarViewModel(car: Car())
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addSubviews()
        setupConstraints()
        addBatterChargeObserver()
        diffTest()
    }
    
    private func diffTest() {
        let c = Counter()
        c.$publishedValue.sink { int in
            print("Published: \(c.publishedValue)", int == c.publishedValue) // 先把新值传递给下游，再才会更新自己的值
        }.store(in: &cancellables)
        
        c.subjectValue.sink { int in
            print("subject", int == c.subjectValue.value)
        }.store(in: &cancellables)
        
        c.publishedValue = 2
        c.subjectValue.value = 2
    }
    
    private func addBatterChargeObserver() {
//        car.onBatteryChargeChanged = { [weak self] newCharge in
//            guard let self = self else { return }
//            self.batteryLabel.text = "The car now has \(newCharge) kwh in its battery"
//        }
//        car.kwhInBattery
//            .sink { [weak self] newCharge in
//                guard let self = self else { return }
//                self.batteryLabel.text = "The car now has \(newCharge) kwh in its battery"
//            }
//            .store(in: &cancellables)
        
//        car.$kwhInBattery
//            .sink { [weak self] newCharge in
//                guard let self = self else { return }
//                self.batteryLabel.text = "The car now has \(newCharge) kwh in its battery"
//            }.store(in: &cancellables)
        carViewModel.batterySubject
            .assign(to: \.text, on: batteryLabel)
            .store(in: &cancellables)
    }
    
    private func addSubviews() {
        view.backgroundColor = .white
        view.addSubview(batteryLabel)
        view.addSubview(driveButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            batteryLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            batteryLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            batteryLabel.widthAnchor.constraint(equalToConstant: 300),
            batteryLabel.heightAnchor.constraint(equalToConstant: 60),
            
            driveButton.widthAnchor.constraint(equalToConstant: 100),
            driveButton.heightAnchor.constraint(equalToConstant: 40),
            driveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            driveButton.topAnchor.constraint(equalTo: batteryLabel.bottomAnchor, constant: 20)
        ])
    }
    
    private lazy var driveButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Drive", for: .normal)
        button.addTarget(self, action: #selector(driveButtonTapped), for: .touchUpInside)
        return button
    }()
    
    @objc func driveButtonTapped() {
        carViewModel.drive(kilometers: 10.0)
    }
    
    private lazy var batteryLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 20)
        label.textColor = .green
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 2
        return label
    }()
}

extension ViewController {
    private func arrayPublisherTest() {
        [1,2,3].publisher
            .print()
            .flatMap(maxPublishers: .max(1)) { int in
                return Array(repeating: int, count: 2).publisher
            }
            .sink { value in
                print("got: \(value)")
            }
            .store(in: &cancellables)
    }

    enum MyError: Error {
        case outofBounds
    }

    func tryMapTest() {
        [1,2,3].publisher
            .tryMap { int in
                guard int < 3 else {
                    throw MyError.outofBounds
                }
                return int * 2
            }
            .sink { completion in
                print("completion")
            } receiveValue: { val in
                print(val)
            }
            .store(in: &cancellables)
    }

    func demoApiCall() {
        let baseUrl = URL(string: "https://www.donnywals.com")!
        ["/", "/the-blog", "/speaking"].publisher
            .toURLSessionDataTaskBeta(baseURL: baseUrl)
            .sink { completion in
                print("Completed with: \(completion)")
            } receiveValue: { result in
                //print(result)
            }
            .store(in: &cancellables)
    }

    //demoApiCall()


    // PassthroughObject, does not hold state.

    func notificationPublisherTest() {
        let notificationCenter = NotificationCenter.default
        let notificationName = UIResponder.keyboardWillShowNotification
        let publisher = notificationCenter.publisher(for: notificationName)
        
        publisher
            .sink { notification in
                print("notification here \(notification)")
            }
            .store(in: &cancellables)
        
        notificationCenter.post(name: notificationName, object: nil)
    }

    func notificationPassthroughTest() {
        let notificationSubject = PassthroughSubject<Notification, Never>()
        let notificationName = UIResponder.keyboardWillShowNotification
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(forName: notificationName, object: nil, queue: nil) { notification in
            notificationSubject.send(notification)
        }
        
        notificationSubject
            .sink { notification in
                print("receive notification from PassthroughSubject \(notification)")
            }
            .store(in: &cancellables)
        notificationCenter.post(Notification(name: notificationName, object: nil))
    }
}

