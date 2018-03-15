//
//  AddViewController.swift
//  Cookbook
//
//  Created by Lukáš Andrlik on 10/03/2018.
//  Copyright © 2018 Dominik Vesely. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa
import SnapKit
import Swinject
import enum Result.NoError

protocol EditViewControlling {
    
}

class EditViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, EditViewControlling {

    private let scrollView = UIScrollView()
    private let recipeNameLabel = UILabel()
    private let recipeNameTextField = UITextField()
    private let separator1 = UIView()
    private let infoTextLabel = UILabel()
    private let infoTextView = UITextView()
    private let separator2 = UIView()
    private let ingredientsLabel = UILabel()
    private let ingredientsStackView = UIStackView()
    private let ingredientAddButton = UIButton()
    private let descriptionLabel = UILabel()
    private let descriptionTextView = UITextView()
    private let separator3 = UIView()
    private let durationLabel = UILabel()
    private let durationTextField = UITextField()
    private let separator4 = UIView()
        
    static let inset = 20
    static let separatorHeight = 1
    
    private let hasIngredient = MutableProperty<Bool>(false)
    private var validIngrediencesSignals = [Signal<Bool, NoError>]()
    private var ingredientsTextFields = [UITextField]()
    private var ingredients = MutableProperty<[String]>([])
    
    private var saveAction: CocoaAction<Any>?
    private var saveButtonItem: UIBarButtonItem?
    private var activeField: UIView?
    private var infoShown = false
    
    var viewModel: EditViewModeling?
    
    // MARK: Lifecycle
     
    deinit {
    }
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeConstraints()
        configureUI()
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
        
        self.title = viewModel!.title
        
        viewModel!.name <~ recipeNameTextField.reactive.textValues.skipNil().producer
        viewModel!.info <~ infoTextView.reactive.textValues.skipNil().producer
        viewModel!.description <~ descriptionTextView.reactive.textValues.skipNil().producer
        viewModel!.ingredients <~ ingredients.producer
        //viewModel.duration <~ durationTextField.reactive.textValues.skipNil().map{Int($0)}.skipNil().producer
        
        viewModel!.saveAction.events.observe(on: UIScheduler()).observe { [weak self]  event in
            switch event {
            case let .failed(error):
                self?.showErrorAlert(error: error)
            case let .value(value):
                if let error = value.error {
                    self?.showErrorAlert(error: error)
                } else {
                    self?.clearContent()
                    self?.closeKeyboard(self as Any)
                    self?.splitViewController?.toggleMasterView()
                }
            case .completed, .interrupted:
                break
            }
        }
        
        viewModel!.saveAction.isExecuting.signal.observe(on: UIScheduler()).observe { [weak self] signal in
            self?.saveButtonItem?.isEnabled = !(signal.value ?? true)
            UIApplication.shared.isNetworkActivityIndicatorVisible = signal.value ?? false
        }
        
        viewModel!.alertMessageSignal.observe(on: UIScheduler()).observe { [weak self] signal in
            switch signal {
            case let .failed(error):
                self?.showErrorAlert(error: error)
            case let .value(value):
                self?.showErrorAlert(error: value)
            case .completed, .interrupted:
                break
            }
        }
        
        recipeNameLabel.text = viewModel!.recipeNameLabelTitle
        infoTextLabel.text = viewModel!.recipeInfoTextLabelTitle
        ingredientsLabel.text = viewModel!.recipeIngredientsLabelTitle
        ingredientAddButton.setTitle(viewModel!.recipeIngredientAddButtonTitle, for: .normal)
        descriptionLabel.text = viewModel!.recipeDescriptionLabelTitle.localized.uppercased()
        durationLabel.text = viewModel!.recipeDurationLabelTitle.localized
    }
    
    // MARK: Layout
    
    func makeConstraints() {
        let superview = self.view!
        
        superview.addSubview(scrollView)
        scrollView.isScrollEnabled = true
        scrollView.backgroundColor = UIColor.theme.white
        scrollView.snp.makeConstraints { (make) -> Void in
            make.width.equalToSuperview()
            make.height.equalToSuperview()
            make.top.equalToSuperview()
            make.left.equalToSuperview()
        }
        
        let inset = EditViewController.inset
        
        scrollView.addSubview(recipeNameLabel)
        recipeNameLabel.textColor = UIColor.theme.blue
        recipeNameLabel.font = UIFont.theme.textBold
        recipeNameLabel.numberOfLines = 0
        recipeNameLabel.backgroundColor = UIColor.theme.white
        recipeNameLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalToSuperview().offset(inset)
            make.width.equalToSuperview().inset(inset)
            make.centerX.equalToSuperview()
        }
        
        scrollView.addSubview(recipeNameTextField)
        recipeNameTextField.delegate = self
        recipeNameTextField.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(recipeNameLabel.snp.bottom).offset(10)
            make.width.equalToSuperview().inset(inset)
            make.centerX.equalToSuperview()
        }
        
        scrollView.addSubview(separator1)
        separator1.backgroundColor = UIColor.theme.lightGray
        separator1.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(recipeNameTextField.snp.bottom).offset(inset)
            make.width.equalToSuperview().inset(inset)
            make.height.equalTo(EditViewController.separatorHeight)
            make.centerX.equalToSuperview()
        }
        
        scrollView.addSubview(infoTextLabel)
        infoTextLabel.textColor = UIColor.theme.blue
        infoTextLabel.font = UIFont.theme.textBold
        infoTextLabel.numberOfLines = 0
        infoTextLabel.backgroundColor = UIColor.theme.white
        infoTextLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(separator1.snp.bottom).offset(inset)
            make.width.equalToSuperview().inset(inset)
            make.centerX.equalToSuperview()
        }
        
        scrollView.addSubview(infoTextView)
        infoTextView.textColor = UIColor.theme.darkGray
        infoTextView.font = UIFont.theme.text
        infoTextView.backgroundColor = UIColor.theme.white
        infoTextView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(infoTextLabel.snp.bottom).offset(10)
            make.width.equalToSuperview().inset(inset)
            make.height.equalTo(100)
            make.centerX.equalToSuperview()
        }
        
        scrollView.addSubview(separator2)
        separator2.backgroundColor = UIColor.theme.lightGray
        separator2.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(infoTextView.snp.bottom).offset(inset)
            make.width.equalToSuperview().inset(inset)
            make.height.equalTo(EditViewController.separatorHeight)
            make.centerX.equalToSuperview()
        }
        
        scrollView.addSubview(ingredientsLabel)
        ingredientsLabel.textColor = UIColor.theme.blue
        ingredientsLabel.font = UIFont.theme.textBold
        ingredientsLabel.numberOfLines = 0
        ingredientsLabel.backgroundColor = UIColor.theme.white
        ingredientsLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(separator2.snp.bottom).offset(inset)
            make.width.equalToSuperview().inset(inset)
            make.centerX.equalToSuperview()
        }
        
        scrollView.addSubview(ingredientsStackView)
        ingredientsStackView.backgroundColor = UIColor.brown
        ingredientsStackView.axis = .vertical;
        ingredientsStackView.distribution = .equalSpacing;
        ingredientsStackView.alignment = .center;
        ingredientsStackView.spacing = 10;
        ingredientsStackView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(ingredientsLabel.snp.bottom)
            make.width.equalToSuperview().inset(inset)
            make.centerX.equalToSuperview()
        }
        
        scrollView.addSubview(ingredientAddButton)
        ingredientAddButton.setTitleColor(UIColor.theme.pink, for: .normal)
        createViewBorder(for: self.ingredientAddButton, flag: false, color: UIColor.theme.pink)
        ingredientAddButton.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(ingredientsStackView.snp.bottom).offset(inset)
            make.width.equalTo(200)
            make.left.equalToSuperview().offset(inset)
        }
        
        scrollView.addSubview(descriptionLabel)
        descriptionLabel.textColor = UIColor.theme.blue
        descriptionLabel.font = UIFont.theme.textBold
        descriptionLabel.numberOfLines = 0
        descriptionLabel.backgroundColor = UIColor.theme.white
        descriptionLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(ingredientAddButton.snp.bottom).offset(inset)
            make.width.equalToSuperview().inset(inset)
            make.centerX.equalToSuperview()
        }
        
        scrollView.addSubview(descriptionTextView)
        descriptionTextView.delegate = self
        descriptionTextView.textColor = UIColor.theme.darkGray
        descriptionTextView.font = UIFont.theme.text
        descriptionTextView.backgroundColor = UIColor.theme.white
        descriptionTextView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(inset)
            make.width.equalToSuperview().inset(inset)
            make.height.equalTo(100)
            make.centerX.equalToSuperview()
        }
        
        scrollView.addSubview(separator3)
        separator3.backgroundColor = UIColor.theme.lightGray
        separator3.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(descriptionTextView.snp.bottom).offset(inset)
            make.width.equalToSuperview().inset(inset)
            make.height.equalTo(EditViewController.separatorHeight)
            make.centerX.equalToSuperview()
        }
        
        scrollView.addSubview(durationLabel)
        durationLabel.numberOfLines = 1
        durationLabel.textColor = UIColor.theme.darkGray
        durationLabel.font = UIFont.theme.text
        durationLabel.backgroundColor = UIColor.theme.white
        durationLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(separator3.snp.bottom).offset(inset)
            make.width.equalTo(50)
            make.left.equalTo(superview.snp.left).offset(inset)
        }
        
        scrollView.addSubview(durationTextField)
        durationTextField.delegate = self
        durationTextField.textColor = UIColor.theme.dimGray
        durationTextField.backgroundColor = UIColor.theme.white
        durationTextField.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(separator3.snp.bottom).offset(inset)
            make.left.equalTo(durationLabel.snp.right)
            make.right.equalTo(superview.snp.right).inset(inset)
        }
        
        scrollView.addSubview(separator4)
        separator4.backgroundColor = UIColor.theme.lightGray
        separator4.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(durationTextField.snp.bottom).offset(inset)
            make.width.equalToSuperview().inset(inset)
            make.height.equalTo(EditViewController.separatorHeight)
            make.centerX.equalToSuperview()
        }
    }
    
    override func viewDidLayoutSubviews() {
        self.scrollView.contentSize.height = self.separator4.frame.maxY + 50
        super.viewDidLayoutSubviews()
    }
    
    // MARK: - UI behaviour setup
    
    func configureUI() {
        guard viewModel != nil else {
            return
        }
        
        edgesForExtendedLayout = []
        
        self.saveAction = CocoaAction(viewModel!.saveAction, { _ in return () })
        self.saveButtonItem = UIBarButtonItem(
            barButtonSystemItem: .save,
            target: self.saveAction,
            action: CocoaAction<Any>.selector as Selector
        )
        
        navigationItem.rightBarButtonItem = self.saveButtonItem
        
        let validRecipeNameSignal = nameTextFieldValidation(for: recipeNameTextField)
        createViewBorder(for: self.recipeNameTextField, flag: false, color: UIColor.theme.pink)
        validRecipeNameSignal.observeValues { [unowned self] flag in
            self.createViewBorder(for: self.recipeNameTextField, flag: flag, color: UIColor.theme.pink)
        }
        
        let validInfoTextSignal = textViewValidation(for: infoTextView)
        createViewBorder(for: infoTextView, flag: false, color: UIColor.theme.pink)
        validInfoTextSignal.observeValues { [unowned self] flag in
            self.createViewBorder(for: self.infoTextView, flag: flag, color: UIColor.theme.pink)
        }
        
        createViewBorder(for: ingredientsStackView, flag: false, color: UIColor.theme.pink)
        let validStackViewSignal = hasIngredient.signal
        validStackViewSignal.observeValues{ [unowned self] flag in
            self.createViewBorder(for: self.ingredientsStackView, flag: flag, color: UIColor.theme.pink)
        }
        
        ingredientAddButton.reactive.controlEvents(.touchUpInside).observeValues { [unowned self] sender in
            self.ingredientsStackView.snp.updateConstraints{ [unowned self] (make) -> Void in
                make.top.equalTo(self.ingredientsLabel.snp.bottom).offset(20)
            }
            let ingredienceTextField = UITextField()
            let validIngredienceTextFieldSignal = self.textFieldValidation(for: ingredienceTextField)
            validIngredienceTextFieldSignal.observeValues{ [unowned self, unowned ingredienceTextField] flag in
                self.createViewBorder(for: ingredienceTextField, flag: flag, color: UIColor.theme.pink)
            }
            self.ingredientsTextFields.append(ingredienceTextField)
            self.validIngrediencesSignals.append(validIngredienceTextFieldSignal)
            self.createViewBorder(for: ingredienceTextField, flag: false, color: UIColor.theme.pink)
            ingredienceTextField.snp.makeConstraints { [unowned self] (make) -> Void in
                make.width.equalTo(self.ingredientsStackView.snp.width)
                make.height.greaterThanOrEqualTo(15)
                self.ingredientsStackView.addArrangedSubview(ingredienceTextField)
                self.hasIngredient.swap(true)
                self.view.setNeedsLayout()
            }
            
            Signal.combineLatest(self.validIngrediencesSignals).map{!$0.contains(false)}.observeValues { flag in
                self.hasIngredient.swap(flag)
            }
        }
        
        let validDescriptionTextSignal = textViewValidation(for: descriptionTextView)
        createViewBorder(for: descriptionTextView, flag: false, color: UIColor.theme.pink)
        validDescriptionTextSignal.observeValues { [unowned self] flag in
            self.createViewBorder(for: self.descriptionTextView, flag: flag, color: UIColor.theme.pink)
        }
        
        let validDurationTextSignal = textFieldNumericValidation(for: durationTextField)
        createViewBorder(for: durationTextField, flag: false, color: UIColor.theme.pink)
        validDurationTextSignal.observeValues { [unowned self] flag in
            self.createViewBorder(for: self.durationTextField, flag: flag, color: UIColor.theme.pink)
        }
        
        Signal.combineLatest(validRecipeNameSignal, validInfoTextSignal, validStackViewSignal, validDescriptionTextSignal, validDurationTextSignal).map{ $0 && $1 && $2 && $3 && $4 }.observeValues {  flag in
            self.saveButtonItem?.isEnabled = flag
            self.viewModel!.inputIsValid.swap(flag)
            if (flag == true) {
                self.viewModel!.duration.swap(Int(self.durationTextField.text!)!)
                self.ingredients.swap(self.ingredientsTextFields.map{ $0.text ?? ""})
            }
        }
        
        registerForKeyboardNotifications()
        
        self.saveButtonItem?.isEnabled = false
    }
    
    func textViewValidation(for view: UITextView) -> Signal<Bool, NoError> {
        return view
            .reactive
            .continuousTextValues
            .skipNil()
            .map { $0.count > 3 }
    }
    
    func textFieldNumericValidation(for field: UITextField) -> Signal<Bool, NoError> {
        return field
            .reactive
            .continuousTextValues
            .skipNil()
            .map { $0.count > 0 && Int($0) != nil && Int($0) != 0}
    }
    
    func textFieldValidation(for field: UITextField) -> Signal<Bool, NoError> {
        return field
            .reactive
            .continuousTextValues
            .skipNil()
            .map { $0.count > 3 }
    }
    
    func nameTextFieldValidation(for field: UITextField) -> Signal<Bool, NoError> {
        return field
            .reactive
            .continuousTextValues
            .skipNil()
            .map { $0.range(of: "Ackee") != nil }
    }
    
    // MARK: - Keyboard

    func registerForKeyboardNotifications() {
        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.numberOfTapsRequired = 1
        tapGestureRecognizer.addTarget(self, action: #selector(closeKeyboard(_:)))
        self.view.addGestureRecognizer(tapGestureRecognizer)
        
        NotificationCenter.default.addObserver(self, selector: #selector(EditViewController.adjustForKeyboard), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(EditViewController.adjustForKeyboard), name: .UIKeyboardWillHide, object: nil)
    }
    
    @objc
    func closeKeyboard(_ sender: Any) {
        recipeNameTextField.resignFirstResponder()
        infoTextView.resignFirstResponder()
        ingredientsTextFields.forEach { $0.resignFirstResponder() }
        descriptionTextView.resignFirstResponder()
        durationTextField.resignFirstResponder()
        activeField = nil
    }
    
    @objc
    func adjustForKeyboard(notification: Notification) {
        let userInfo = notification.userInfo!
        
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == Notification.Name.UIKeyboardWillHide {
            scrollView.contentInset = UIEdgeInsets.zero
        } else {
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
        }
        
        scrollView.scrollIndicatorInsets = scrollView.contentInset
        
        if activeField != nil && notification.name == Notification.Name.UIKeyboardWillShow {
            let point = CGPoint(x: 0, y: max(scrollView.contentSize.height - activeField!.frame.maxY + keyboardViewEndFrame.height, 0))
            scrollView.setContentOffset(point, animated: true)
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField === recipeNameTextField && self.infoShown == false {
            showInfoAlert(time: 2, info: "edit.recipeName.info".localized, completion: { [unowned self] in
                self.infoShown = true
                self.recipeNameTextField.becomeFirstResponder()
            })
            return false
        } else if textField === recipeNameTextField {
            return true
        } else {
            activeField = textField
            return true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === recipeNameTextField {
            self.infoShown = false
        }
        activeField?.resignFirstResponder()
        activeField = nil
        return true
    }
    
    // MARK: - UITextViewDelegate
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        activeField = textView
        return true
    }
    
    func textViewShouldReturn(_ textView: UITextView) -> Bool {
        activeField?.resignFirstResponder()
        activeField = nil
        return true
    }
    
    // MARK: Internal Helpers
    
    private func clearContent() {
        recipeNameTextField.text = ""
        createViewBorder(for: recipeNameTextField, flag: false, color: UIColor.theme.pink)
        infoTextView.text = ""
        createViewBorder(for: infoTextView, flag: false, color: UIColor.theme.pink)
        descriptionTextView.text = ""
        createViewBorder(for: descriptionTextView, flag: false, color: UIColor.theme.pink)
        durationTextField.text = ""
        createViewBorder(for: durationTextField, flag: false, color: UIColor.theme.pink)
        
        ingredientsStackView.subviews.forEach { $0.removeFromSuperview() }
        saveButtonItem?.isEnabled = false
        scrollView.setNeedsLayout()
    }
    
}
