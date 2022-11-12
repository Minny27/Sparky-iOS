//
//  HomeCustomShareVC.swift
//  Sparky-iOS
//
//  Created by SeungMin on 2022/11/12.
//

import UIKit
import UniformTypeIdentifiers
import MobileCoreServices
import RxSwift
import RxCocoa
import SnapKit
import Then
import SwiftLinkPreview
import Kingfisher

final class HomeCustomShareVC: UIViewController {
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let viewModel = AddTagViewModel()
    private let previewViewModel = PreviewViewModel()
    
    var urlString: String? = nil
    
    private let scrapBackgroundView = UIView().then {
        $0.backgroundColor = .gray100
    }
    
    private let scrapView = UIView().then {
        $0.backgroundColor = .sparkyWhite
        $0.layer.cornerRadius = 8
    }
    
    private var scrapImageView = UIImageView().then {
        $0.layer.cornerRadius = 4
        $0.contentMode = .scaleAspectFit
    }
    
    private var scrapTitleLabel = CustomVAlignLabel().then {
        $0.font = .bodyBold2
        $0.textAlignment = .left
        $0.textColor = .black
        $0.numberOfLines = 2
        $0.verticalAlignment = .top
    }
    
    private var scrapSubTitleLabel = CustomVAlignLabel().then {
        $0.font = .bodyRegular1
        $0.textAlignment = .left
        $0.textColor = .black
        $0.numberOfLines = 2
        $0.verticalAlignment = .top
    }
    
    private let dividerView = UIView().then {
        $0.backgroundColor = .gray200
    }
    
    private let tagTitleLabel = UILabel().then {
        $0.text = "추가할 태그"
        $0.font = .subTitleBold1
        $0.textAlignment = .center
        $0.textColor = .sparkyBlack
    }
    
    private let addTagCollectionView = TagCollectionView(frame: CGRect(x: 0, y: 0, width: 100, height: 100),
                                                         collectionViewLayout: TagCollectionViewFlowLayout()).then({
        $0.backgroundColor = .background
    })
    
    private let memoTitleLabel = UILabel().then {
        $0.text = "메모"
        $0.font = .subTitleBold1
        $0.textAlignment = .center
        $0.textColor = .sparkyBlack
    }
    
    private let memoTextViewPlaceHolder = "메모를 입력하세요"
    private lazy var memoTextView = UITextView().then {
        $0.text = memoTextViewPlaceHolder
        $0.font = .bodyRegular1
        $0.textColor = .gray400
        $0.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.gray300.cgColor
        $0.layer.cornerRadius = 8
        $0.showsVerticalScrollIndicator = false
        $0.delegate = self
    }
    
    private let saveButton = UIButton().then {
        $0.setTitle("저장하기", for: .normal)
        $0.setTitleColor(.sparkyWhite, for: .normal)
        $0.titleLabel?.font = .bodyBold2
        $0.layer.cornerRadius = 8
        $0.backgroundColor = .sparkyBlack
    }
    
    // MARK: - LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .background
        setupNavBar()
        setupConstraints()
        bindViewModel()
        setupScrap()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    private func setupNavBar() {
        self.navigationController?.navigationBar.backgroundColor = .gray100
        self.navigationController?.navigationBar.tintColor = .black
        
        let ncBarTitleLabel = UILabel().then {
            $0.text = "스크랩 저장"
            $0.font = .subTitleBold1
            $0.textAlignment = .center
            $0.textColor = .sparkyBlack
        }
        
        let ncBarCancelButton = UIBarButtonItem(image: UIImage(named: "clear"),
                                                style: .plain,
                                                target: self,
                                                action: nil)
        ncBarCancelButton.rx.tap.subscribe { _ in
            let error = NSError(domain: "sparky.bundle.identifier",
                                code: 0,
                                userInfo: [NSLocalizedDescriptionKey: "An error description"])
            self.extensionContext?.cancelRequest(withError: error)
        } onError: { error in
            print(error)
        }.disposed(by: disposeBag)
        self.navigationItem.titleView = ncBarTitleLabel
        self.navigationItem.leftBarButtonItem = ncBarCancelButton
    }
    
    private func setupConstraints() {
        self.view.addSubview(scrapBackgroundView)
        scrapBackgroundView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.left.equalTo(view)
            $0.right.equalTo(view)
            $0.height.equalTo(122)
        }
        
        self.scrapBackgroundView.addSubview(scrapView)
        scrapView.snp.makeConstraints {
            $0.top.equalTo(scrapBackgroundView).offset(12)
            $0.left.equalTo(scrapBackgroundView).offset(20)
            $0.right.equalTo(scrapBackgroundView).offset(-20)
            $0.height.equalTo(94)
        }
        
        self.scrapView.addSubview(scrapImageView)
        scrapImageView.snp.makeConstraints {
            $0.top.equalTo(scrapView).offset(12)
            $0.left.equalTo(scrapView).offset(12)
            $0.bottom.equalTo(scrapView).offset(-12)
            $0.width.equalTo(100)
        }
        
        self.scrapView.addSubview(scrapTitleLabel)
        scrapTitleLabel.snp.makeConstraints {
            $0.top.equalTo(scrapView).offset(12)
            $0.left.equalTo(scrapImageView.snp.right).offset(12)
            $0.right.equalTo(scrapView).offset(-12)
        }
        
        self.scrapView.addSubview(scrapSubTitleLabel)
        scrapSubTitleLabel.snp.makeConstraints {
            $0.top.equalTo(scrapTitleLabel.snp.bottom).offset(8)
            $0.left.equalTo(scrapImageView.snp.right).offset(12)
            $0.right.equalTo(scrapView).offset(-12)
        }
        
        self.view.addSubview(dividerView)
        dividerView.snp.makeConstraints {
            $0.top.equalTo(scrapBackgroundView.snp.bottom)
            $0.left.equalTo(view)
            $0.right.equalTo(view)
            $0.height.equalTo(6)
        }
        
        self.view.addSubview(tagTitleLabel)
        tagTitleLabel.snp.makeConstraints {
            $0.top.equalTo(dividerView.snp.bottom).offset(20)
            $0.left.equalTo(view).offset(20)
        }
        
        self.view.addSubview(addTagCollectionView)
        addTagCollectionView.snp.makeConstraints {
            $0.top.equalTo(tagTitleLabel.snp.bottom).offset(9)
            $0.left.equalTo(view).offset(20)
            $0.right.equalTo(view).offset(-20)
        }
        
        self.view.addSubview(memoTitleLabel)
        memoTitleLabel.snp.makeConstraints {
            $0.top.equalTo(addTagCollectionView.snp.bottom).offset(36)
            $0.left.equalTo(view).offset(20)
        }
        
        self.view.addSubview(memoTextView)
        memoTextView.snp.makeConstraints {
            $0.top.equalTo(memoTitleLabel.snp.bottom).offset(8)
            $0.left.equalTo(view).offset(20)
            $0.right.equalTo(view).offset(-20)
            $0.height.equalTo(100)
        }
        
        self.view.addSubview(saveButton)
        saveButton.snp.makeConstraints {
            $0.left.equalTo(view).offset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            $0.right.equalTo(view).offset(-20)
            $0.height.equalTo(50)
        }
    }
    
    private func bindViewModel() {
        viewModel.addTagList
            .bind(to: addTagCollectionView.rx.items(cellIdentifier: TagCollectionViewCell.identifier, cellType: TagCollectionViewCell.self)) { index, tag, cell in
                cell.setupConstraints()
                cell.setupTagButton(tag: tag)
            }.disposed(by: disposeBag)
        
        addTagCollectionView.rx
            .itemSelected
            .subscribe(onNext: { indexPath in
                if self.viewModel.addTagList.value.count > 0 {
                    switch indexPath.row {
                    case self.viewModel.addTagList.value.count - 1:
                        self.presentTagBottomSheetVC()
                        break
                        
                    default:
                        self.viewModel.addTagList.remove(at: indexPath.row)
                        break
                    }
                }
            }).disposed(by: disposeBag)
        
        saveButton.rx.tap
            .subscribe { _ in
                let preview = self.previewViewModel.preview
                let memo = self.memoTextView.text
                var tagIdList = [Int]()
                
                for i in 0 ..< self.viewModel.addTagList.value.count - 1 {
                    tagIdList.append(self.viewModel.addTagList.value[i].tagId)
                }
                
                let newScrapRequest = ScrapRequest(title: preview?.title ?? "",
                                                   subTitle: preview?.subtitle ?? "",
                                                   memo: memo ?? "",
                                                   imgUrl: preview?.thumbnailURLString ?? "",
                                                   scpUrl: preview?.scrapURLString ?? "",
                                                   tags: tagIdList)
                self.saveMyScrap(scrapRequest: newScrapRequest)
            }.disposed(by: disposeBag)
    }
    
    private func saveMyScrap(scrapRequest: ScrapRequest) {
        self.navigationController?.popViewController(animated: false)
        self.dismiss(animated: false)
        
        HomeServiceProvider.shared
            .saveScrap(scrapRequest: scrapRequest)
            .map(PostResultResponse.self)
            .subscribe { response in
                print("code: \(response.code)")
                print("message: \(response.message)")
                
                if response.code == "0000" {
                    print("---요청 성공!!!---")
                    //                    self.navigationController?.popViewController(animated: false)
                    //                    self.dismiss(animated: false)
                } else {
                    print("---응답 실패!!!---")
                }
                
            } onFailure: { error in
                print("---요청 실패---")
                print(error)
            }.disposed(by: disposeBag)
        
    }
    
    private func presentTagBottomSheetVC() {
        let tagBottomSheetVC = HomeTagBottomSheetVC()
        tagBottomSheetVC.newTagCVDelegate = self
        tagBottomSheetVC.modalPresentationStyle = .overFullScreen
        self.present(tagBottomSheetVC, animated: false)
    }
    
    //    func convertToNoneType(tagList: [Tag]) -> [Tag] {
    //        var newTagList = tagList
    //        if newTagList[newTagList.count - 1].buttonType == .add { newTagList.removeLast() }
    //
    //        for i in 0..<newTagList.count {
    //            newTagList[i] = Tag(text: newTagList[i].text,
    //                                backgroundColor: newTagList[i].backgroundColor,
    //                                buttonType: .none)
    //        }
    //        return newTagList
    //    }
    
    
    private func setupScrap() {
        if let urlString = urlString {
            setupScrap(urlString: urlString)
        } else {
            if let item = extensionContext?.inputItems.first as? NSExtensionItem {
                print("item is not nil")
                accessWebpageProperites(extentionItem: item)
            }
        }
    }
    
    private func setupScrap(urlString: String) {
        self.previewViewModel.fetchPreview(urlString: urlString) { preview in
            do {
                print("CustomShareVC response - \(preview)")
                self.scrapImageView.setupImageView(frameSize: CGSize(width: 100, height: 70), url: URL(string: preview?.thumbnailURLString ?? ""))
                self.scrapTitleLabel.text = preview?.title ?? ""
                self.scrapSubTitleLabel.text = preview?.subtitle ?? ""
                self.view.layoutIfNeeded()
            } catch {
                
            }
        }
    }
    
    
    private func accessWebpageProperites(extentionItem: NSExtensionItem) {
        if let attachments = extentionItem.attachments {
            for attachment: NSItemProvider in attachments {
                if attachment.hasItemConformingToTypeIdentifier("public.url") {
                    attachment.loadItem(forTypeIdentifier: "public.url",
                                        options: nil) { (url, error) in
                        
                        print("Web Page URL - \(url)")
                        
                        if let url = url as? URL {
                            let urlString = url.absoluteString
                            self.setupScrap(urlString: urlString)
                        }
                        
                        // 크롤링 코드
                        //                        if let url = url as? URL {
                        //                            DispatchQueue.main.async {
                        //                                CrwalManager().getTistoryScrap(url: url) { scrap in
                        //                                    self.scrapImageView.image = UIImage(data: try! Data(contentsOf: scrap.thumbnailURL))
                        //                                    self.scrapTitleLabel.text = scrap.title
                        //                                    self.scrapSubTitleLabel.text = scrap.subTitle
                        //                                }
                        //                            }
                        //                        }
                    }
                }
            }
        }
    }
    
    //    private func setupImageView(imageView: UIImageView, url: URL?) {
    //        print("imageView.frame.size - \(imageView.frame.size)")
    //        let processor = DownsamplingImageProcessor(size: imageView.frame.size)
    //        imageView.kf.setImage(with: url,
    //                              placeholder: UIImage(systemName: "person.circle"),
    //                              options: [
    //                                .processor(processor),
    //                                .loadDiskFileSynchronously,
    //                                .cacheOriginalImage,
    //                                .transition(.fade(0.25)),
    //                              ]) { result in
    //                                  switch result {
    //                                  case .success(let value):
    //                                      print("Task done for: \(value.source.url?.absoluteString ?? "")")
    //                                  case .failure(let error):
    //                                      print("error: \(error)")
    //                                  }
    //                              }
    //    }
}

extension HomeCustomShareVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == memoTextViewPlaceHolder {
            textView.text = nil
            textView.textColor = .sparkyBlack
            textView.layer.borderColor = UIColor.sparkyBlack.cgColor
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if memoTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = memoTextViewPlaceHolder
            textView.textColor = .gray400
            textView.layer.borderColor = UIColor.gray300.cgColor
        }
    }
}

extension HomeCustomShareVC: NewTagCVDelegate {
    func sendNewTagList(tag: Tag) {
        let newTag = Tag(tagId: tag.tagId,
                         name: tag.name,
                         color: tag.color,
                         buttonType: .delete)
        
        if !viewModel.addTagList.value.contains(where: { tag in
            if tag == newTag {
                return true
            }
            return false
        }) {
            viewModel.addTagList.insert(newTag, at: 0)
        }
    }
}