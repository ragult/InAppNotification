//
//  StroriesViewController.swift
//  alltimecommunicator
//
//  Created by Suresh Mopidevi on 30/01/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import UIKit

class StroriesViewController: UIViewController {
    var storyTitleText: String?
    var storyText: String?

    @IBOutlet var storyTitle: UILabel!
    @IBOutlet var story: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        storyTitle.text = storyTitleText
        story.text = storyText

//        storyTitle.text = "The Rat and the Elephant"
//        story.text = "Some people say that rats are ugly creatures. When they see a rat running along, they go ee-yuck! Well I don’t know about you, but I’ve always thought that this was rather rude. Rats can have hurt feelings too you know! In any case, when I catch sight of my reflection in a stream, I think I’m rather cute. \n Just recently, I was trotting along the King’s Highway, in my sweet little way, when I heard a great commotion on the road up ahead. Who or what is causing all that fuss? I wondered.When I got closer, I saw the King himself, riding along on top of a great fat lump of an elephant. \n The crowd of onlookers were ooo-ing and aah-ing full of admiration for that stupid beast with a nose that’s far too big for her face. She’s much uglier than me, I thought. So I started to spring up and down and say: “Hey everyone! Why not look at me? I’m such a cutie-pie! I could join the King’s household and be a royal rat, if only there was any justice in the world.” At first, nobody noticed me. \n They were all too busy ogling that stupid elephant. Little did I know that riding behind the elephant in a carriage, was the princess, and she was holding a beastly cat in her arms. When he caught sight of me, the cat leapt out of the carriage and started to chase me. I had to run for my life, and popped down a hole just in time before the cat could eat me up."
        story.textAlignment = .justified
        // Do any additional setup after loading the view.
    }

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
     }
     */
}
