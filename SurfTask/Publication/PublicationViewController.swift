//
//  PublicationViewControllerv.swift
//  SurfTask
//
//  Created by Артём Калинин on 16.09.2021.
//

import UIKit

class PublicationViewController: UIViewController {

    var publication = News()
    lazy var contentViewSize = CGSize(width: view.frame.width, height: view.frame.height + 3000)

    private let headlineLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont.systemFont(ofSize: 28, weight: .heavy)
        label.textAlignment = .center
        return label
    }()

    private let trailTextLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        return label
    }()

    private let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        return imageView
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont.italicSystemFont(ofSize: 15)
        label.textColor = UIColor.gray
        return label
    }()

    private let authorLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont.italicSystemFont(ofSize: 15)
        label.textColor = UIColor.gray
        return label
    }()

    private let bodyLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()

    func getContentSize() -> CGSize {
        return CGSize(width: view.frame.width, height: 20 + headlineLabel.frame.height +
                        15 + trailTextLabel.frame.height +
                        12 + thumbnailImageView.frame.height +
                        12 + authorLabel.frame.height +
                        5 + dateLabel.frame.height +
                        20 + bodyLabel.frame.height + 20)
    }

    lazy var scrollView: UIScrollView = {
        let view = UIScrollView(frame: .zero)
        view.frame = self.view.bounds
        view.contentSize = contentViewSize
        return view
    }()

    lazy var contentView: UIView = {
        let view = UIView()
        view.frame.size = contentViewSize
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(headlineLabel)
        contentView.addSubview(trailTextLabel)
        contentView.addSubview(thumbnailImageView)
        contentView.addSubview(authorLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(bodyLabel)

        setHeadLineLabelConstraints()
        setTrailTextLabelConstraints()
        setThumbnailImageViewConstraints()
        setAuthorLabelConstraints()
        setDateLabelConstraints()
        setBodyLabelConstraints()

        setElements(with: publication)
        view.backgroundColor = UIColor.white
    }

    func setElements(with model: News) {
        headlineLabel.text = model.headline
        trailTextLabel.text = model.trailText
        dateLabel.text = model.date
        authorLabel.text = model.author
        bodyLabel.text = model.bodyText

        if let stringURL = model.thumbnail {
            guard let URL = URL(string: stringURL) else { return }

            DispatchQueue.global(qos: .utility).async {
                if let data = try? Data(contentsOf: URL) {

                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        self.thumbnailImageView.image = UIImage(data: data)
                    }
                } else {
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        self.thumbnailImageView.image = UIImage(named: "theguardian.png")
                    }
                }
            }
        } else {
            thumbnailImageView.image = UIImage(named: "theguardian.png")
        }
    }

    func setScrollViewFrame() {
        scrollView.frame = view.bounds
        scrollView.contentSize = contentViewSize
        contentView.frame.size = contentViewSize
    }

    func setHeadLineLabelConstraints() {
        headlineLabel.translatesAutoresizingMaskIntoConstraints = false
        headlineLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        headlineLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20).isActive = true
        headlineLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30).isActive = true
        headlineLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30).isActive = true
    }

    func setTrailTextLabelConstraints() {
        trailTextLabel.translatesAutoresizingMaskIntoConstraints = false
        trailTextLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        trailTextLabel.topAnchor.constraint(equalTo: headlineLabel.bottomAnchor, constant: 15).isActive = true
        trailTextLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        trailTextLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
    }

    func setThumbnailImageViewConstraints() {
        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        thumbnailImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        thumbnailImageView.topAnchor.constraint(equalTo: trailTextLabel.bottomAnchor, constant: 12).isActive = true
        thumbnailImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        thumbnailImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        thumbnailImageView.widthAnchor.constraint(equalTo: thumbnailImageView.heightAnchor,
                                                  multiplier: 16/9).isActive = true
    }

    func setAuthorLabelConstraints() {
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        authorLabel.topAnchor.constraint(equalTo: thumbnailImageView.bottomAnchor, constant: 12).isActive = true
        authorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        authorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
    }

    func setDateLabelConstraints() {
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: 5).isActive = true
        dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
    }

    func setBodyLabelConstraints() {
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        bodyLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 20).isActive = true
        bodyLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        bodyLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
    }
}
