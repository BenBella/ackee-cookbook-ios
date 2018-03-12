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

class DetailViewController: BaseViewController {
    
    let scrollView = UIScrollView()
    let headerImageView = UIImageView()
    let infoLabel = UILabel()
    let ingredientsTitleLabel = UILabel()
    let ingredientsStackView = UIStackView()
    let descriptionTitleLabel = UILabel()
    let descriptionLabel = UILabel()
    let footerView = UIView()
    let scoreEvaluateLabel = UILabel()
    let scoreEvaluateButtonsWrapper = UIView()
    
    var viewModel: DetailViewModel?
    
    var disposable: Disposable?
    
    static let inset = 20
    
    // MARK: - Lifecycle
    
    deinit {
        disposable?.dispose()
    }
    
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        makeConstraints()
        bindViewModel()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Bindings
    
    func bindViewModel() {
        guard viewModel != nil else {
            return
        }
        
        self.title = viewModel?.title
        
        viewModel!.active <~ isActive()
        
        viewModel!.contentChangesSignal.observe(on: UIScheduler()).observe { [unowned self]  signal in
            switch signal {
            case let .failed(error):
                self.showErrorAlert(error: error)
            case .value(_): do {
                    if let viewModel = self.viewModel {
                        self.infoLabel.text = viewModel.recipeInfo
                        self.ingredientsTitleLabel.text = viewModel.recipeIngredientsLabelTitle
                        self.updateIngredientsStackView(viewModel.recipeIngredients)
                        self.descriptionTitleLabel.text = viewModel.recipeDescriptionLabelTitle
                        self.descriptionLabel.text = viewModel.recipeDescription
                        self.scoreEvaluateLabel.text = viewModel.recipeScoreEvaluateLabelTitle
                        self.view.layoutIfNeeded()
                        self.scrollView.contentSize.height = self.footerView.frame.maxY
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
    }
    
    // MARK: Layout
    
    func makeConstraints() {
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
        
        let inset = DetailViewController.inset
        
        scrollView.addSubview(infoLabel)
        infoLabel.numberOfLines = 0
        infoLabel.backgroundColor = UIColor.darkGray
        infoLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(headerImageView.snp.bottom)
            make.width.equalToSuperview().inset(inset)
            make.centerX.equalToSuperview()
        }
        
        scrollView.addSubview(ingredientsTitleLabel)
        ingredientsTitleLabel.numberOfLines = 1
        ingredientsTitleLabel.backgroundColor = UIColor.darkGray
        ingredientsTitleLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(infoLabel.snp.bottom)
            make.width.equalToSuperview().inset(inset)
            make.centerX.equalToSuperview()
        }
        
        scrollView.addSubview(ingredientsStackView)
        ingredientsStackView.backgroundColor = UIColor.brown
        ingredientsStackView.axis = .vertical;
        ingredientsStackView.distribution = .equalSpacing;
        ingredientsStackView.alignment = .center;
        ingredientsStackView.spacing = 5;
        ingredientsStackView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(ingredientsTitleLabel.snp.bottom)
            make.width.equalToSuperview().inset(inset)
            make.centerX.equalToSuperview()
        }
        
        scrollView.addSubview(descriptionTitleLabel)
        descriptionTitleLabel.numberOfLines = 1
        descriptionTitleLabel.backgroundColor = UIColor.darkGray
        descriptionTitleLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(ingredientsStackView.snp.bottom)
            make.width.equalToSuperview().inset(inset)
            make.centerX.equalToSuperview()
        }
        
        scrollView.addSubview(descriptionLabel)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.backgroundColor = UIColor.darkGray
        descriptionLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(descriptionTitleLabel.snp.bottom)
            make.width.equalToSuperview().inset(inset)
            make.centerX.equalToSuperview()
        }
        
        scrollView.addSubview(footerView)
        footerView.backgroundColor = UIColor.blue
        footerView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(descriptionLabel.snp.bottom)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(100)
        }
        
        footerView.addSubview(scoreEvaluateLabel)
        scoreEvaluateLabel.textAlignment = .center
        scoreEvaluateLabel.backgroundColor = UIColor.purple
        scoreEvaluateLabel.snp.makeConstraints { (make) -> Void in
            make.width.equalToSuperview().inset(inset)
            make.height.equalTo(20)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-10)
        }
        
        footerView.addSubview(scoreEvaluateButtonsWrapper)
        scoreEvaluateButtonsWrapper.backgroundColor = UIColor.purple
        scoreEvaluateButtonsWrapper.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(100)
            make.height.equalTo(20)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(10)
        }
        
        var prevButton: UIButton?
        for index in 1...5 {
            let starButton = UIButton(type: .custom)
            starButton.tag = index
            starButton.setImage(#imageLiteral(resourceName: "ic_star_white"), for: .normal)
            starButton.reactive.controlEvents(.touchUpInside).observeValues { [unowned self] button in
                //self.viewModel?.evaluteRecipe(score: button.tag)
            }
            scoreEvaluateButtonsWrapper.addSubview(starButton)
            if prevButton == nil {
                starButton.snp.makeConstraints{ (make) -> Void in
                    make.height.width.equalTo(20)
                    make.centerY.equalTo(scoreEvaluateButtonsWrapper.snp.centerY)
                    make.left.equalTo(scoreEvaluateButtonsWrapper.snp.left)
                }
                prevButton = starButton
            } else {
                starButton.snp.makeConstraints{ (make) -> Void in
                    make.height.width.equalTo(20)
                    make.centerY.equalTo(scoreEvaluateButtonsWrapper.snp.centerY)
                    make.left.equalTo(prevButton!.snp.right)
                }
                prevButton = starButton
            }
        }
        
    }
    
    func updateIngredientsStackView(_ ingredients: [String]) {
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
    
}

