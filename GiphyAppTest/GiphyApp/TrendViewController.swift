//
//  ViewController.swift
//  GiphyApp
//
//  Created by Константин Малков on 18.05.2022.
//

import UIKit

class TrendViewController: UIViewController, UICollectionViewDataSource, UISearchBarDelegate,UIGestureRecognizerDelegate{

    var data: [Data] = [] //хранилище после декодирования json
    private var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
    //константа зажатия на экран для перехода на новый вью
    private let gesture: UILongPressGestureRecognizer = {
        let gesture = UILongPressGestureRecognizer()
        gesture.minimumPressDuration = 0.5
        gesture.numberOfTouchesRequired = 1
        gesture.addTarget(TrendViewController.self, action: #selector(presentShareSheet))
        return gesture
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let collectionView = collectionView
        collectionView.scrollsToTop = true
        collectionView.backgroundColor = .systemBackground
        collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: ImageCollectionViewCell.identifier)
        collectionView.dataSource = self
        collectionView.addGestureRecognizer(gesture)
        collectionView.topAnchor.constraint(equalTo: collectionView.topAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor).isActive = true
        
        self.collectionView = collectionView
        
        view.addSubview(collectionView)
        trendingURL()
    }
    
    //вывод представления на монитор
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.frame.size.width, height: view.frame.size.height)
    }

    //функция мозаичного отображения гифок
    static func createLayout() -> UICollectionViewCompositionalLayout {
    
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(2/3),
            heightDimension: .fractionalHeight(1)))
        item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)

        let verticalItem = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalHeight(0.5)))
        verticalItem.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
        
        let verticalGroup = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1/3),
                heightDimension: .fractionalHeight(1)),
                subitem: verticalItem, count: 2)
        
        let tripleItem = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalHeight(1)))
        
        let tripletGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(1/3)), subitem: tripleItem, count: 3)
        
        let horizontalGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1)),
                subitems: [item,verticalGroup])
        
        let verticalGroupItems = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(3/5)),
            subitems: [horizontalGroup, tripletGroup])
        
        let section = NSCollectionLayoutSection(group: verticalGroupItems)
       
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    
    
    
//MARK: - objc methods segue for sharing
//в процессе разработки
    @objc private func presentShareSheet() {
        let image = trendingURL.self
        let url = URL(string: "https://www.google.com")
        let shareSheetVC = UIActivityViewController(activityItems: [image,url! ], applicationActivities: nil)
        present(shareSheetVC, animated: true)
    }
//MARK: - API's and Decoders
    //функция наследования API трендов для главного экрана
    func trendingURL() {
        let urlTrending = "https://api.giphy.com/v1/gifs/trending?api_key=lJBQo9pJXOzZtd8uYULP2eVb0TXujlem&limit=50&rating=g"
        guard let url = URL(string: urlTrending) else {
            return
        }
        //проверка на подключение
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _ , error in
            guard let data = data, error == nil else {
                return
            }
            //декодирование json кода в нужный нам формат и наследование его в переменную data
            do{
                let jsonResult = try JSONDecoder().decode(APIResponse.self, from: data) //декодирования
                DispatchQueue.main.async {
                    self?.data = jsonResult.data //присвоение данных к массиву
                    self?.collectionView.reloadData() //обновление представления после прогрузки
                }
                print(jsonResult.data.count) //проверка работоспособности через консоль и проверка кол-ва загруженного материала
            }
            catch{
                print(error)
            }
            print("Got data")
        }
        task.resume()
    }
    //MARK: - helpful methods
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let imageURLString = data[indexPath.row].images.downsized.url //подгрузка фото в строки
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier:ImageCollectionViewCell.identifier,
            for: indexPath) as? ImageCollectionViewCell else {
            return UICollectionViewCell()
        }
        //функция конфигурации и добавления материала во вью
        cell.configure(with: imageURLString)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
}

//MARK: - Help materials
//let urlTrending = "https://api.giphy.com/v1/gifs/trending?api_key=lJBQo9pJXOzZtd8uYULP2eVb0TXujlem&limit=25&rating=g"
//let urlSearching = "https://api.giphy.com/v1/gifs/search?api_key=lJBQo9pJXOzZtd8uYULP2eVb0TXujlem&q=animal&limit=25&offset=0&rating=g&lang=en"
