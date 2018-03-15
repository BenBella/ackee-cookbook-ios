//
//  File.swift
//  Cookbook
//
//  Created by Lukáš Andrlik on 10/03/2018.
//  Copyright © 2018 Dominik Vesely. All rights reserved.
//

import Foundation
import ReactiveSwift
import ReactiveCocoa
import Unbox
import Result

protocol DetailViewModeling {
    
    var recipeId: String? { set get }
    var active: MutableProperty<Bool> { get }
    var refreshSignal: Signal<Void, NoError> { get }
    var refreshObserver: Signal<Void, NoError>.Observer { get }
    
    var title: String { get }
    var item: MutableProperty<RecipeDetail> { get }
    var contentChangesSignal: Signal<Bool, NoError> { get }
    var isLoading: MutableProperty<Bool> { get }
    var alertMessageSignal: Signal<RequestError, NoError> { get }
    var recipeIngredientsLabelTitle: String { get }
    var recipeDescriptionLabelTitle: String { get }
    var recipeScoreEvaluateLabelTitle: String { get }
    var recipeName: String { get }
    var recipeDuration: Int { get }
    var recipeScore: Double { get }
    var recipeInfo: String { get }
    var recipeDescription: String { get }
    var recipeIngredients: [String] { get }
    
    var evaluateAction: Action<Int, Any?, RequestError> { get set }
}

class DetailViewModel : DetailViewModeling {

    // MARK: - Dependencies
    var api: CookbookAPIServicing
    
    // MARK: - Input
    var recipeId: String? {
        didSet {
    
            //setup()
        }
    }
    let active = MutableProperty(false)
    var refreshSignal: Signal<Void, NoError>
    var refreshObserver: Signal<Void, NoError>.Observer
    
    // MARK: - Output
    let title = "detail.title".localized
    var item: MutableProperty<RecipeDetail> = MutableProperty(RecipeDetail())
    var contentChangesSignal: Signal<Bool, NoError>
    var isLoading: MutableProperty<Bool>
    var alertMessageSignal: Signal<RequestError, NoError>
    let recipeIngredientsLabelTitle = "detail.ingredients.title".localized
    let recipeDescriptionLabelTitle =  "detail.description.title".localized
    let recipeScoreEvaluateLabelTitle = "detail.rate.title".localized
    var recipeName = ""
    var recipeDuration = 0
    var recipeScore = 0.0
    var recipeInfo = ""
    var recipeDescription = ""
    var recipeIngredients = [String]()
    
    private var contentChangesObserver: Signal<Bool, NoError>.Observer
    private var alertMessageObserver: Signal<RequestError, NoError>.Observer
    private var recipeDetail: RecipeDetail? {
        didSet {
            if let recipeDetail = recipeDetail {
                recipeName = recipeDetail.name
                recipeDuration = recipeDetail.duration
                recipeScore = recipeDetail.score
                recipeInfo = recipeDetail.info
                recipeDescription = recipeDetail.description
                recipeIngredients = recipeDetail.ingredients
            }
        }
    }
    
    // Actions
    lazy var evaluateAction: Action<Int, Any?, RequestError> = { [unowned self] (input: Int) in
        return Action<Int, Any?, RequestError>() { [unowned self] (input: Int) in
            let parameters = EvaluateParameters(
                score: input
            )
            return self.api.evaluateRecipe(id: self.recipeId ?? "", parameters: parameters)
        }
    }(0)
    
    // MARK: - Lifecycle
    
    init(api: CookbookAPIServicing) {
        self.api = api

        let (refreshSignal, refreshObserver) = Signal<Void, NoError>.pipe()
        self.refreshObserver = refreshObserver
        self.refreshSignal = refreshSignal
        
        let (contentChangesSignal, contentChangesObserver) = Signal<Bool, NoError>.pipe()
        self.contentChangesSignal = contentChangesSignal
        self.contentChangesObserver = contentChangesObserver
        
        let isLoading = MutableProperty(false)
        self.isLoading = isLoading
        
        let (alertMessageSignal, alertMessageObserver) = Signal<RequestError, NoError>.pipe()
        self.alertMessageSignal = alertMessageSignal
        self.alertMessageObserver = alertMessageObserver
        
        // Trigger refresh when view becomes active
        active.producer
            .filter { $0 && self.recipeId != nil }
            .map { _ in () }
            .start(refreshObserver)
 
        SignalProducer<Void, NoError>(refreshSignal)
            .on(value: { [unowned self] _ in self.isLoading.swap(true)} )
            .flatMap(FlattenStrategy.latest) { [unowned self] _ in
                return self.api.getRecipeDetail(id: self.recipeId ?? "").flatMapError { error in
                    self.alertMessageObserver.send(value: error)
                    return SignalProducer(value: [])
                }
            }
            .on(value: {[weak self]  _ in self?.isLoading.swap(false)} )
            .skipNil()
            .start({ [weak self] signal in
                self?.recipeDetail = signal.value! as? RecipeDetail
                if let observer = self?.contentChangesObserver {
                    observer.send(value: true)
                }
            })
    }
}
