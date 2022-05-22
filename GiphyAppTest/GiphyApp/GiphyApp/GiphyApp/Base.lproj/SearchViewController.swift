//
//  SearchViewController.swift
//  GiphyApp
//
//  Created by Константин Малков on 21.05.2022.
//

import UIKit

class SearchViewController: UIViewController, UICollectionViewDataSource, UISearchBarDelegate {
    
    var data: [Data] = []
    private var collectionView: UICollectionView?
    let searchbar = UISearchBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let layout = UICollectionViewFlowLayout()
        
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: view.frame.size.width/2,
                                 height: view.frame.size.width/2)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: ImageCollectionViewCell.identifier)
        collectionView.dataSource = self
        collectionView.backgroundColor = .systemBackground
        
        self.collectionView = collectionView
        searchbar.delegate = self
        searchbar.searchTextField.placeholder = "Enter your request"
        searchbar.returnKeyType = .search
        searchbar.keyboardAppearance = .light
        view.addSubview(searchbar)
        view.addSubview(collectionView)
    }
    //вывод представления на монитор
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        searchbar.frame = CGRect(x: 10, y: view.safeAreaInsets.top, width: view.frame.size.width-20, height: 50)
        collectionView?.frame = CGRect(x: 0, y: view.safeAreaInsets.top+55, width: view.frame.size.width, height: view.frame.size.height-55)
    }
//MARK: - Inherit API
    func searchingURL(query: String){
        let urlSearching = "https://api.giphy.com/v1/gifs/search?api_key=lJBQo9pJXOzZtd8uYULP2eVb0TXujlem&q=\(query)&limit=30&offset=0&rating=g&lang=en"
        guard let url = URL(string: urlSearching) else {
            return
        }
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _ , error in
            guard let data = data, error == nil else {
                return
            }
            do{
                let jsonResult = try JSONDecoder().decode(APIResponse.self, from: data) //декодирования
                DispatchQueue.main.async {
                    self?.data = jsonResult.data //присвоение данных к массиву
                    self?.collectionView?.reloadData()
                }
                print(jsonResult.data.count)
            }
            catch{
                print(error)
            }
            
            print("Got data")

        }
        task.resume()
    }
    
//MARK: - Helpful methods
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let imageURLString = data[indexPath.row].images.downsized.url //подгрузка фото в строки
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.identifier,
                                                            for: indexPath) as? ImageCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: imageURLString)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let text = searchbar.text {
            data = []
            collectionView?.reloadData()
            searchingURL(query: text)
        }
    }
}
