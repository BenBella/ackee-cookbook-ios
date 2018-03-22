//
//  DetailViewController.swift
//  Cookbook-Test-Project
//
//  Created by Dominik Vesely on 12/01/2017.
//  Copyright © 2017 Dominik Vesely. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa

class DetailViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let headerImageView = UIImageView()
    private let headerImageOverlayView = UIView()
    private let recipeNameLabel = UILabel()
    private let stripWrapperView = UIView()
    private let scoreWrapperView = UIView()
    private let durationIcon = UIImageView()
    private let durationLabel = UILabel()
    private let infoLabel = UILabel()
    private let ingredientsTitleLabel = UILabel()
    private let ingredientsStackView = UIStackView()
    private let descriptionTitleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let footerView = UIView()
    private let scoreEvaluateLabel = UILabel()
    private let scoreEvaluateButtonsWrapper = UIView()
    
    private var evaluateButtons = [UIButton]()
    private var evaluateAction: CocoaAction<Any>?
    
    var viewModel: DetailViewModeling?
    
    static let inset = 20
    
    // MARK: - Lifecycle
    
    deinit {
    }
    
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        hideSubviews()
        makeConstraints()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Bindings
    
    // swiftlint:disable function_body_length cyclomatic_complexity
    private func bindViewModel() {
        guard viewModel != nil else {
            return
        }
        
        self.title = viewModel!.title
        
        viewModel!.active <~ isActive()
        
        viewModel!.contentChangesSignal.observe(on: UIScheduler()).observe { [unowned self]  signal in
            switch signal {
            case let .failed(error):
                self.showErrorAlert(error: error)
            case .value: do {
                    if let viewModel = self.viewModel {
                        self.recipeNameLabel.text = viewModel.recipeName
                        self.infoLabel.text = viewModel.recipeInfo
                        self.ingredientsTitleLabel.text = viewModel.recipeIngredientsLabelTitle.uppercased()
                        self.durationIcon.image = #imageLiteral(resourceName: "ic_time_white")
                        self.updateScoreView(viewModel.recipeScore)
                        self.durationLabel.text = viewModel.recipeDuration.createDurationString()
                        self.updateIngredientsStackView(viewModel.recipeIngredients)
                        self.descriptionTitleLabel.text = viewModel.recipeDescriptionLabelTitle.uppercased()
                        self.descriptionLabel.text = viewModel.recipeDescription
                        self.scoreEvaluateLabel.text = viewModel.recipeScoreEvaluateLabelTitle.uppercaseFirst
                        self.view.layoutIfNeeded()
                        self.scrollView.contentSize.height = self.footerView.frame.maxY
                        self.showSubviews()
                    }
                }
            case .completed, .interrupted:
                break
            }
        }
    
        viewModel!.isLoading.producer.observe(on: UIScheduler()).start { isLoading in
             UIApplication.shared.isNetworkActivityIndicatorVisible = isLoading.value ?? false
        }
        
        viewModel!.alertMessageSignal.observe(on: UIScheduler()).observe { [unowned self] signal in
            switch signal {
            case let .failed(error):
                self.showErrorAlert(error: error)
            case let .value(value):
                self.showErrorAlert(error: value)
            case .completed, .interrupted:
                break
            }
        }
        
        viewModel!.evaluateAction.events.observe(on: UIScheduler()).observe { [weak self]  event in
            switch event {
            case let .failed(error):
                self?.showErrorAlert(error: error)
            case let .value(value):
                if let error = value.error {
                    self?.showErrorAlert(error: error)
                } else {
                    self?.showInfoAlert(time: 2, info: "detail.rate.thankYou".localized)
                }
            case .completed, .interrupted:
                break
            }
        }
        
        self.evaluateAction = CocoaAction(viewModel!.evaluateAction, { sender in
            // swiftlint:disable force_cast
            return (sender as! UIButton).tag }
        )
        
        evaluateButtons.forEach {
            $0.addTarget(self.evaluateAction, action: CocoaAction<Any>.selector as Selector, for: .touchUpInside)
        }
    }
    
    // MARK: Layout
    // swiftlint:disable function_body_length
    private func makeConstraints() {
        let superview = self.view!
        
        superview.addSubview(scrollView)
        scrollView.isScrollEnabled = true
        scrollView.backgroundColor = UIColor.theme.white
        scrollView.snp.makeConstraints { (make) -> Void in
            make.size.equalToSuperview()
            make.top.equalToSuperview()
            make.left.equalToSuperview()
        }
        
        scrollView.addSubview(headerImageView)
        headerImageView.image = #imageLiteral(resourceName: "img_big")
        headerImageView.snp.makeConstraints { (make) -> Void in
            make.width.equalToSuperview()
            make.height.equalTo(superview.snp.width)
            make.top.equalToSuperview()
            make.left.equalToSuperview()
        }
        
        headerImageView.addSubview(headerImageOverlayView)
        headerImageOverlayView.backgroundColor = UIColor.theme.transparentBlack
        headerImageOverlayView.snp.makeConstraints { (make) -> Void in
            make.size.equalTo(headerImageView)
            make.left.equalTo(headerImageView)
            make.top.equalTo(headerImageView)
        }
        
        headerImageOverlayView.addSubview(stripWrapperView)
        stripWrapperView.backgroundColor = UIColor.theme.pink
        stripWrapperView.snp.makeConstraints { (make) -> Void in
            make.width.equalToSuperview()
            make.height.equalTo(superview.frame.width / 7)
            make.bottom.equalToSuperview()
        }
        
        stripWrapperView.addSubview(scoreWrapperView)
        scoreWrapperView.backgroundColor = UIColor.theme.clear
        scoreWrapperView.snp.makeConstraints { (make) -> Void in
            make.centerY.equalTo(stripWrapperView.snp.centerY)
            make.left.equalTo(stripWrapperView.snp.left).offset(30)
            make.height.equalTo(22)
        }
        
        stripWrapperView.addSubview(durationIcon)
        durationIcon.backgroundColor = UIColor.theme.clear
        durationIcon.snp.makeConstraints { (make) -> Void in
            make.centerY.equalTo(stripWrapperView.snp.centerY)
            make.left.equalTo(scoreWrapperView.snp.right)
            make.width.height.equalTo(22)
        }
        
        stripWrapperView.addSubview(durationLabel)
        durationLabel.backgroundColor = UIColor.theme.clear
        durationLabel.textColor = UIColor.theme.white
        durationLabel.textAlignment = .right
        durationLabel.snp.makeConstraints { (make) -> Void in
            make.centerY.equalTo(stripWrapperView.snp.centerY)
            make.left.equalTo(durationIcon.snp.right).offset(10)
            make.right.equalTo(stripWrapperView.snp.right).inset(30)
            make.height.equalTo(22)
        }
        
        headerImageView.addSubview(recipeNameLabel)
        recipeNameLabel.numberOfLines = 0
        recipeNameLabel.font = UIFont.theme.bigTitleBold
        recipeNameLabel.textColor = UIColor.theme.white
        recipeNameLabel.backgroundColor = UIColor.theme.clear
        recipeNameLabel.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(headerImageView).offset(20)
            make.width.equalToSuperview().inset(20)
            make.bottom.equalTo( stripWrapperView.snp.top).inset(-20)
        }
        
        let inset = DetailViewController.inset
        
        scrollView.addSubview(infoLabel)
        infoLabel.numberOfLines = 0
        infoLabel.font = UIFont.theme.text
        infoLabel.backgroundColor = UIColor.theme.white
        infoLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(headerImageView.snp.bottom).offset(inset)
            make.width.equalToSuperview().inset(inset)
            make.centerX.equalToSuperview()
        }
        
        scrollView.addSubview(ingredientsTitleLabel)
        ingredientsTitleLabel.numberOfLines = 1
        ingredientsTitleLabel.font = UIFont.theme.textBold
        ingredientsTitleLabel.textColor = UIColor.theme.blue
        ingredientsTitleLabel.backgroundColor = UIColor.theme.white
        ingredientsTitleLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(infoLabel.snp.bottom).offset(inset)
            make.width.equalToSuperview().inset(inset)
            make.centerX.equalToSuperview()
        }
        
        scrollView.addSubview(ingredientsStackView)
        ingredientsStackView.backgroundColor = UIColor.theme.white
        ingredientsStackView.axis = .vertical
        ingredientsStackView.distribution = .equalSpacing
        ingredientsStackView.alignment = .center
        ingredientsStackView.spacing = 5
        ingredientsStackView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(ingredientsTitleLabel.snp.bottom).offset(inset)
            make.width.equalToSuperview().inset(inset)
            make.centerX.equalToSuperview()
        }
        
        scrollView.addSubview(descriptionTitleLabel)
        descriptionTitleLabel.numberOfLines = 1
        descriptionTitleLabel.font = UIFont.theme.textBold
        descriptionTitleLabel.textColor = UIColor.theme.blue
        descriptionTitleLabel.backgroundColor = UIColor.theme.white
        descriptionTitleLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(ingredientsStackView.snp.bottom).offset(inset)
            make.width.equalToSuperview().inset(inset)
            make.centerX.equalToSuperview()
        }
        
        scrollView.addSubview(descriptionLabel)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.font = UIFont.theme.text
        descriptionLabel.backgroundColor = UIColor.theme.white
        descriptionLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(descriptionTitleLabel.snp.bottom).offset(inset)
            make.width.equalToSuperview().inset(inset)
            make.centerX.equalToSuperview()
        }
        
        scrollView.addSubview(footerView)
        footerView.backgroundColor = UIColor.blue
        footerView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(inset)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(superview.frame.width / 3)
        }
        
        footerView.addSubview(scoreEvaluateLabel)
        scoreEvaluateLabel.textAlignment = .center
        scoreEvaluateLabel.textColor = UIColor.theme.white
        scoreEvaluateLabel.font = UIFont.theme.titleBold
        scoreEvaluateLabel.backgroundColor = UIColor.theme.clear
        scoreEvaluateLabel.snp.makeConstraints { (make) -> Void in
            make.width.equalToSuperview().inset(inset)
            make.height.equalTo(20)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-20)
        }
        
        footerView.addSubview(scoreEvaluateButtonsWrapper)
        scoreEvaluateButtonsWrapper.backgroundColor = UIColor.theme.blue
        scoreEvaluateButtonsWrapper.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(200)
            make.height.equalTo(40)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(20)
        }
        
        var prevButton: UIButton?
        for index in 1...5 {
            let starButton = UIButton(type: .custom)
            starButton.tag = index
            starButton.setImage(#imageLiteral(resourceName: "ic_star_white"), for: .normal)
            self.evaluateButtons.append(starButton)
            scoreEvaluateButtonsWrapper.addSubview(starButton)
            if prevButton == nil {
                starButton.snp.makeConstraints { (make) -> Void in
                    make.height.width.equalTo(40)
                    make.centerY.equalTo(scoreEvaluateButtonsWrapper.snp.centerY)
                    make.left.equalTo(scoreEvaluateButtonsWrapper.snp.left)
                }
                prevButton = starButton
            } else {
                starButton.snp.makeConstraints { (make) -> Void in
                    make.height.width.equalTo(40)
                    make.centerY.equalTo(scoreEvaluateButtonsWrapper.snp.centerY)
                    make.left.equalTo(prevButton!.snp.right)
                }
                prevButton = starButton
            }
        }
        
    }
    
    private func updateIngredientsStackView(_ ingredients: [String]) {
        ingredientsStackView.arrangedSubviews.forEach({ ingredientsStackView.removeArrangedSubview($0) })
        for ingredient in ingredients {
            let ingredienceLabel = UILabel()
            ingredienceLabel.numberOfLines = 0
            ingredienceLabel.text = " ∙  " +  ingredient
            ingredienceLabel.snp.makeConstraints { (make) -> Void in
                make.width.equalTo(ingredientsStackView.snp.width)
                make.height.greaterThanOrEqualTo(15)
                ingredientsStackView.addArrangedSubview(ingredienceLabel)
            }
        }
    }
    
    // MARK: Internal Helpers
    
    private func updateScoreView(_ score: Double) {
        scoreWrapperView.subviews.forEach({ $0.removeFromSuperview() })
        var prevIcon: UIImageView?
        let rounded = Int(score.rounded())
        for index in 0...rounded {
            guard index < 5 else {
                break
            }
            let starIcon = UIImageView()
            starIcon.image = #imageLiteral(resourceName: "ic_star_white")
            scoreWrapperView.addSubview(starIcon)
            if prevIcon == nil {
                starIcon.snp.makeConstraints { (make) -> Void in
                    make.height.width.equalTo(18)
                    make.centerY.equalTo(scoreWrapperView.snp.centerY)
                    make.left.equalTo(scoreWrapperView.snp.left)
                }
                prevIcon = starIcon
            } else {
                starIcon.snp.makeConstraints { (make) -> Void in
                    make.height.width.equalTo(18)
                    make.centerY.equalTo(scoreWrapperView.snp.centerY)
                    make.left.equalTo(prevIcon!.snp.right)
                }
                prevIcon = starIcon
            }
        }
    }
    
    private func showSubviews() {
        UIView.animate(withDuration: 0.3, animations: {
            self.scrollView.alpha = 1.0
        })
    }
    
    private func hideSubviews() {
        UIView.animate(withDuration: 0.0, animations: {
            self.scrollView.alpha = 0.0
        })
    }
    
}
