//
//  ViewController.swift
//  TableViewEx
//
//  Created by 김종권 on 2021/03/13.
//

import UIKit
import RxSwift
import RxCocoa
import JGProgressHUD

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var dataSource = [String]()
    let refreshControl = UIRefreshControl()
    let bag = DisposeBag()
    @IBOutlet weak var button: UIButton!

    lazy var hud: JGProgressHUD = {
        let loader = JGProgressHUD(style: .dark)
        return loader
    }()

    func showLoading() {
        DispatchQueue.main.async {
            self.hud.show(in: self.view, animated: true)
        }
    }

    func hideLoading() {
        DispatchQueue.main.async {
            self.hud.dismiss(animated: true)
        }
    }

    let refreshLoading = PublishRelay<Bool>() // ViewModel에 있다고 가정

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = ["첫 번째", "두 번째", "세 번째"]
        for value in 0...50 {
            dataSource.append(String(describing: value))
        }
        setUpView()
        setUpInputBinding()
        setUpOutputBinding()
    }

    private func setUpView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "MyCell", bundle: nil), forCellReuseIdentifier: "MyCell")

        // 상단 refresh
        refreshControl.endRefreshing()
//        tableView.refreshControl = refreshControl
    }

    private func setUpInputBinding() {
        refreshControl.rx.controlEvent(.valueChanged)
            .bind(onNext: { [weak self] _ in
                // tableView update: viewModel.updateDataSource()
                // 아래 이벤트가 viewModel에서 발생한다고 가정
                DispatchQueue.main.asyncAfter(wallDeadline: .now() + 3) { [weak self] in
                    self?.refreshLoading.accept(true)
                }
            }).disposed(by: bag)

        button.rx.tap
            .bind(onNext: { [weak self] in
                UIView.animate(withDuration: 1.2) { [weak self] in
                    self?.tableView.contentOffset.y = 100
                }
            }).disposed(by: bag)
    }

    private func setUpOutputBinding() {
        // viewModel로부터
//        refreshLoading
//            .bind(to: refreshControl.rx.isRefreshing)
//            .disposed(by: bag)
    }

}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell") as! MyCell
        cell.bind(dataSource[indexPath.row])
        return cell
    }

    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y // frame영역의 origin에 비교했을때의 content view의 현재 origin 위치
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height // 화면에는 frame만큼 가득 찰 수 있기때문에 frame의 height를 빼준 것

        // 스크롤 할 수 있는 영역보다 더 스크롤된 경우 (하단에서 스크롤이 더 된 경우)
        if maximumOffset < currentOffset {
            // viewModel.loadNextPage()
            showLoading() // 데이터 로딩 중 표시
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                self?.hideLoading()
            }
        }
    }

}
