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

class DetailViewModel {
    
    // MARK: - Dependencies
    var api: CookbookAPIService
    
    // MARK: - Input
    var recipeId: String?
    let active = MutableProperty(false)
    let refreshSignal: Signal<Void, NoError>
    let refreshObserver: Signal<Void, NoError>.Observer
    
    // MARK: - Output
    let title = "detail.title".localized
    var item: MutableProperty<RecipeDetail>? = MutableProperty(RecipeDetail())
    let contentChangesSignal: Signal<Bool, NoError>
    let isLoading: MutableProperty<Bool>
    let alertMessageSignal: Signal<RequestError, NoError>
    let recipeIngredientsLabelTitle = "detail.ingredients.title".localized
    let recipeDescriptionLabelTitle =  "detail.description.title".localized
    let recipeScoreEvaluateLabelTitle = "detail.rate.title".localized
    var recipeName = ""
    var recipeDuration = 0
    var recipeScore = 0.0
    var recipeInfo = ""
    var recipeDescription = ""
    var recipeIngredients = [String]()
    
    private let contentChangesObserver: Signal<Bool, NoError>.Observer
    private let alertMessageObserver: Signal<RequestError, NoError>.Observer
    private var recipeDetail: RecipeDetail? {
        didSet {
            recipeName = recipeDetail!.name
            recipeDuration = recipeDetail!.duration
            recipeScore = recipeDetail!.score
            recipeInfo = recipeDetail!.info
            recipeDescription = recipeDetail!.description
            recipeIngredients = recipeDetail!.ingredients
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
    
    init(api: CookbookAPIService, recipeId: String) {
        self.api = api
        self.recipeId = recipeId
        
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
            .filter { $0 }
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
