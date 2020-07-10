//
//  HomeViewModelTests.swift
//  MovieBrowserTests
//
//  Created by Mohseen Shaikh on 29/04/20.
//  Copyright © 2020 XYZ. All rights reserved.
//

import XCTest
@testable import Movie_Browser

class HomeViewModelTests: XCTestCase {
    
    /// Subject Under Test
    var sut: HomeViewModel!
    
    /// Mock API Service
    var mockApiService: MockAPIService!
    
    // MARK: Lifeccycle methods
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        super.setUp()
        
        mockApiService = MockAPIService()
        sut = HomeViewModel(apiService: mockApiService)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
        mockApiService = nil
        
        super.tearDown()
    }

   // MARK: Tests
    
    func test_didFetch_popularMovies_api() {
        // When
        sut.fetchMostPopularMovies()
        
        // Then
        XCTAssertTrue(mockApiService.didfetchPopularMovies, "Fetch the data from the api service invoked")
    }
    
    func test_updateView_after_fetchingMovies() {
        
        // Given
        let homeViewSpy = HomeViewSpy()
        sut.reloadCollectionData = homeViewSpy.input
        
        // When
        XCTAssertNotNil(sut.reloadCollectionData)
        sut.fetchMostPopularMovies()
        
        // Then
        XCTAssertTrue(!sut.movieCollection.isEmpty, "Din't load the movies data")
        XCTAssertTrue(homeViewSpy.updateViewCalled, "Views update should be invoked after movie data")
    }
}

// MARK: - Test Doubles

class MockAPIService: APIServiceProtocol {
    
    /// Determine whether the api fetch was invoked or not.
    var didfetchPopularMovies: Bool = false
    
    /// Mocks the APIServiceProtocol conformance to fetch popular movies
    func fetchPopularMoviesData(pageNumber: Int,
                                completion: @escaping (Result<ServiceResponseVO, Error>) -> Void) {
        didfetchPopularMovies = true
        
        do {
            /// Loads data from a json file stored in the target.
            guard let json = JSONHelper.loadJSONFile("popular-movies", bundle: Bundle(for: HomeViewModelTests.self)) else {
                completion(.failure(JSONError.jsonFileNotFound(filePath: "popular-movies")))
                return
            }
            
            let response = try JSONDecoder().decode(ServiceResponseVO.self, from: json)
            completion(.success(response))
        } catch {
            completion(.failure(JSONError.jsonFileNotFound(filePath: "popular-movies")))
        }
    }
}

class HomeViewSpy {
    
    /// Determine whether view's update was called or not.
    var updateViewCalled: Bool = false
    
    /// Input closure for view.
    var input: (() -> Void)?
    
    init() {
        input = { [weak self] in
            self?.updateViewCalled = true
        }
    }
}

