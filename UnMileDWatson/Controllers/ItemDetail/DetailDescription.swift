//
//  DetailDescription.swift
//  UnMile
//
//  Created by user on 2/29/20.
//  Copyright © 2020 Moghees Sheikh. All rights reserved.
//

import UIKit

class DetailDescription: BaseViewController {

    @IBOutlet weak var descriptionDetailTextView: UITextView!
    var selectedProduct: Product?
    override func viewDidLoad() {
        super.viewDidLoad()
        var htmlString = """
            <h2>Uses Of loprin</h2>\n" +
            "\n" +
            "<p>Aspirin is&nbsp;<strong>used</strong>&nbsp;to reduce fever and relieve mild to moderate pain from conditions such as muscle aches, toothaches, common cold, and headaches. It may also be&nbsp;<strong>used</strong>&nbsp;to reduce pain and swelling in conditions such as arthritis. Aspirin is known as a salicylate and a nonsteroidal anti-inflammatory drug (NSAID).</p>\n" +
            "\n" +
            "<h2>How to use</h2>\n" +
            "\n" +
            "<p>Read the&nbsp;<a href=\"https://www.tabletwise.com/\">medicine</a>&nbsp;guide provided by your pharmacist, your doctor, or the medicine company. If you have any questions related to&nbsp;<a href=\"https://www.tabletwise.com/loprin-tablet\">Loprin</a>, ask your doctor or pharmacist. Use Loprin Tablet as per the instructions provided by your doctor.</p>\n" +
            "\n" +
            "<p>Loprin Tablet is a&nbsp;<a href=\"https://www.tabletwise.com/health/pain\">pain</a>&nbsp;reliever. Pain relievers work the best if used as soon as you feel any pain. They may not work as well if they are delayed until the pain has worsened.</p>\n" +
            "\n" +
            "<h2>Loprin Side-effects</h2>\n" +
            "\n" +
            "<p>The following side-effects may commonly occur when using&nbsp;<a href=\"https://www.tabletwise.com/loprin-tablet\">Loprin Tablet</a>. If any of these side-effects worsen or last for a long time, you should consult with your doctor:</p>\n" +
            "\n" +
            "<ul>\n" +
            "\t<li>difficulty in breathing</li>\n" +
            "\t<li><a href=\"https://www.tabletwise.com/health/skin-rash\">skin rash</a></li>\n" +
            "\t<li>viral infections of the nose and throat</li>\n" +
            "</ul>\n" +
            "\n" +
            "<p>The following severe side-effects may also occur when using&nbsp;<a href=\"https://www.tabletwise.com/loprin-tablet\">Loprin Tablet</a>:</p>\n" +
            "\n" +
            "<ul>\n" +
            "\t<li>\n" +
            "\t<p>Lyell&#39;s&nbsp;<a href=\"https://www.tabletwise.com/health/syndrome\">syndrome</a></p>\n" +
            "\n" +
            "\t<p>Symptoms:&nbsp;severe skin reactions</p>\n" +
            "\t</li>\n" +
            "\t<li>\n" +
            "\t<p>Fast heartbeat</p>\n" +
            "\t</li>\n" +
            "\t<li>\n" +
            "\t<p>Loss of&nbsp;<a href=\"https://www.tabletwise.com/health/hearing\">hearing</a></p>\n" +
            "\t</li>\n" +
            "\t<li>\n" +
            "\t<p>Severe&nbsp;<a href=\"https://www.tabletwise.com/health/bleeding\">bleeding</a>&nbsp;in the stomach or intestines</p>\n" +
            "\t</li>\n" +
            "</ul>\n" +
            "\n" +
            "<p>Your doctor has prescribed this&nbsp;<a href=\"https://www.tabletwise.com/loprin-tablet\">Loprin</a>&nbsp;because they have judged that the benefits outweigh the risks posed by&nbsp;<a href=\"https://www.tabletwise.com/health/drug-reactions\">side-effects</a>. Many people using this medicine do not have serious side-effects. This is not a complete list of possible side-effects for&nbsp;<a href=\"https://www.tabletwise.com/loprin-tablet\">Loprin</a>.</p>\n" +
            "\n" +
            "<p>If you experience side-effects or notice other side-effects not listed above, contact your doctor for medical advice. You may also report side-effects to your local food and drug administration authority. You can look up the drug authority contact information from the&nbsp;<a href=\"https://www.tabletwise.com/drug-authority\">Drug Authority Finder</a>&nbsp;at TabletWise.com.</p>\n" +
            "\n" +
            "<p><strong>Read more:&nbsp;</strong><a href=\"https://www.tabletwise.com/loprin-tablet/side-effects\">Side-effects and Allergic Reactions of Loprin by Severity and Frequency</a></p>\n" +
            "\n" +
            "<p>&nbsp;</p>\n" +
            "\n" +
            "<h2>Warnings</h2>\n" +
            "\n" +
            "<h4>Allergic to Loprin</h4>\n" +
            "\n" +
            "<p>This medicine may lead to an increased risk of allergic conditions. Use of this medicine in such patients may lead to the development of symptoms like facial swelling and skin&nbsp;<a href=\"https://www.tabletwise.com/health/rashes\">rashes</a>.</p>\n" +
            "\n" +
            "<h4>Active Stomach Ulcer Disease</h4>\n" +
            "\n" +
            "<p>Patients with swelling in the food pipe, stomach, and intestines are at risk when using this medicine. Such patients may develop a risk of gastric ulceration and gastrointestinal&nbsp;<a href=\"https://www.tabletwise.com/health/bleeding\">bleeding</a>. Avoid the use of Loprin in patients with a history of&nbsp;<a href=\"https://www.tabletwise.com/health/peptic-ulcer\">ulcers</a>&nbsp;in the stomach or intestines.</p>\n" +
            "\n" +
            "<h4>Reye&#39;s Syndrome</h4>\n" +
            "\n" +
            "<p>Children who are recovering from&nbsp;<a href=\"https://www.tabletwise.com/health/chickenpox\">chickenpox</a>&nbsp;or flu-like symptoms are at an increased risk when using this medicine. Such patients may develop changes in behavior with symptoms of&nbsp;<a href=\"https://www.tabletwise.com/health/nausea\">nausea</a>&nbsp;and vomiting and further chances of development of the swelling in the brain and liver (Reye&#39;s&nbsp;<a href=\"https://www.tabletwise.com/health/syndrome\">syndrome</a>). Consult with your doctor before using Loprin in such patients.</p>\n" +
            "\n" +
            "<h4>Use of Anticoagulant or Antiplatelet Medicines</h4>\n" +
            "\n" +
            "<p>Patients undergoing&nbsp;<a href=\"https://www.tabletwise.com/health/anticoagulants\">anticoagulants</a>&nbsp;and antiplatelet therapy are at an increased risk when using this medicine. Such patients have an increased risk of&nbsp;<a href=\"https://www.tabletwise.com/health/bleeding\">bleeding</a>&nbsp;when using this medicine. Such patients should avoid using this medicine when undergoing therapy with anticoagulants or antiplatelet drug.</p>\n" +
            "\n" +
            "<h4>Heavy Menstrual Bleeding</h4>\n" +
            "\n" +
            "<p>These patients are at an increased risk when using this medicine.</p>\n" +
            "\n" +
            "<h4>Family History of Lapp Lactase Deficiency</h4>\n" +
            "\n" +
            "<p>Patients with family history of Lapp lactase deficiency are at an increased risk when using this medicine.</p>\n" +
            "\n" +
            "<h2>Interactions with Loprin</h2>\n" +
            "\n" +
            "<p>When two or more&nbsp;<a href=\"https://www.tabletwise.com/\">medicines</a>&nbsp;are taken together, it can change how the medicines work and increase the risk of side-effects. In medical terms, this is called as a&nbsp;<a href=\"https://www.tabletwise.com/health/drug-reactions\">Drug Interaction</a>.</p>\n" +
            "\n" +
            "<p>This page does not contain all the possible interactions of Loprin Tablet. Share a list of all medicines that you use with your doctor and pharmacist. Do not start, stop, or change the dose of any&nbsp;<a href=\"https://www.tabletwise.com/\">medicines</a>&nbsp;without the approval of your doctor.</p>\n" +
            "\n" +
            "<h4>Anticonvulsants</h4>\n" +
            "\n" +
            "<p>Loprin Tablet interacts with&nbsp;<a href=\"https://www.tabletwise.com/medicine/phenytoin\">phenytoin</a>&nbsp;and&nbsp;<a href=\"https://www.tabletwise.com/medicine/valproic\">valproic</a>&nbsp;acid, which are used to treat&nbsp;<a href=\"https://www.tabletwise.com/health/epilepsy\">epilepsy</a>. Using these medicines simultaneously decreases phenytoin levels in the body and increases levels of valproic acid in the body. Patients should take necessary precautions while taking both drugs in combination.</p>\n" +
            "\n" +
            "<h4>Anticoagulants</h4>\n" +
            "\n" +
            "<p>There may be an interaction of&nbsp;<a href=\"https://www.tabletwise.com/loprin-tablet\">Loprin</a>&nbsp;with&nbsp;<a href=\"https://www.tabletwise.com/health/anticoagulants\">anticoagulants</a>, which are used to prevent blood clotting. Patients taking anticoagulants with Loprin may experience increased risk of&nbsp;<a href=\"https://www.tabletwise.com/health/bleeding\">bleeding</a>. Patients should take necessary precautions while taking both drugs in combination as the risk of bleeding is high.</p>\n" +
            "\n" +
            "<h4>NSAIDs</h4>\n" +
            "\n" +
            "<p><a href=\"https://www.tabletwise.com/loprin-tablet\">Loprin Tablet</a>&nbsp;may interact with nonsteroidal anti-inflammatory drugs (<a href=\"https://www.tabletwise.com/health/nsaids\">NSAIDs</a>), which are used to treat&nbsp;<a href=\"https://www.tabletwise.com/health/fever\">fever</a>&nbsp;and&nbsp;<a href=\"https://www.tabletwise.com/health/pain\">pain</a>. NSAIDs can&nbsp;<a href=\"https://www.tabletwise.com/medicine/interferon\">interfere</a>&nbsp;with the anti-platelet effect of low-dose&nbsp;<a href=\"https://www.tabletwise.com/medicine/aspirin\">aspirin</a>&nbsp;and result in an increased risk of&nbsp;<a href=\"https://www.tabletwise.com/health/bleeding\">bleeding</a>. Take this medicine at least 8 hours after taking a dosage of other NSAIDs (such as,&nbsp;<a href=\"https://www.tabletwise.com/medicine/ibuprofen\">Ibuprofen</a>).</p>\n" +
            "\n" +
            "<h4>Antimetabolites</h4>\n" +
            "\n" +
            "<p>Your doctor&#39;s guidelines may need to be followed while taking this medicine along with&nbsp;<a href=\"https://www.tabletwise.com/medicine/methotrexate\">methotrexate</a>, which is a medicine which is used to treat&nbsp;<a href=\"https://www.tabletwise.com/health/cancer\">cancer</a>. This medicine reduces the removal of methotrexate in the urine by the kidneys. This causes a decrease in the production of blood cells responsible for providing immunity to the body. Patients should not take Loprin and methotrexate in combination.</p>\n" +
            "\n" +
            "<h4>Renin-Angiotensin System (RAS) Inhibitors</h4>\n" +
            "\n" +
            "<p>Special instructions need to be followed while taking this medicine along with renin-angiotensin system (RAS) inhibitors, which are medicines used in the treatment of high blood pressure. Taking these medicines together may result in kidney failure. Monitoring of the functioning of the kidneys is required while using this combination of medicines.</p>\n" +
            "\n" +
            "<h4>Urine Alkalizer Drugs</h4>\n" +
            "\n" +
            "<p>Your doctor&#39;s guidelines may need to be followed while taking this medicine along with&nbsp;<a href=\"https://www.tabletwise.com/medicine/antacids\">antacids</a>, or&nbsp;<a href=\"https://www.tabletwise.com/medicine/citrates\">citrates</a>, which are used to prevent&nbsp;<a href=\"https://www.tabletwise.com/health/gout\">gout</a>&nbsp;or kidney stones. Taking Loprin with&nbsp;<a href=\"https://www.tabletwise.com/health/antacids\">antacids</a>&nbsp;and&nbsp;<a href=\"https://www.tabletwise.com/medicine/citrate\">citrates</a>&nbsp;increases the removal of Loprin from the body. This can decrease the effectiveness of Loprin.</p>\n" +
            "\n" +
            "<h4>Antidiabetics</h4>\n" +
            "\n" +
            "<p>Special instructions need to be followed while taking this medicine along with sulphonylureas, which are used to treat high blood&nbsp;<a href=\"https://www.tabletwise.com/medicine/sugar\">sugar</a>&nbsp;levels. This medicine increases the blood&nbsp;<a href=\"https://www.tabletwise.com/medicine/sugars\">sugar</a>&nbsp;lowering effect of sulphonylureas. Patients should take necessary precautions while taking both drugs in combination.</p>\n" +
            "\n" +
            "<h4>Glycopeptide Antibiotics</h4>\n" +
            "\n" +
            "<p>Loprin Tablet interacts with&nbsp;<a href=\"https://www.tabletwise.com/medicine/vancomycin\">vancomycin</a>, which is a medicine that is used to treat bacterial infections. Using both medicines together may increase the chances for harmful effects to ear which may lead to loss of&nbsp;<a href=\"https://www.tabletwise.com/health/hearing\">hearing</a>. Patients should take necessary precautions while taking both drugs in combination.</p>\n" +
            "\n" +
            "<h4>Antiprogestins</h4>\n" +
            "\n" +
            "<p>There may be an interaction of&nbsp;<a href=\"https://www.tabletwise.com/loprin-tablet\">Loprin</a>&nbsp;with&nbsp;<a href=\"https://www.tabletwise.com/medicine/mifepristone\">mifepristone</a>, which is used to abort a&nbsp;<a href=\"https://www.tabletwise.com/health/pregnancy\">pregnancy</a>. Avoid the use of Loprin until 8-12 days after taking mifepristone.</p>\n" +
            "\n" +
            "<h4>Uricosuric Agents</h4>\n" +
            "\n" +
            "<p><a href=\"https://www.tabletwise.com/loprin-tablet\">Loprin Tablet</a>&nbsp;may interact with&nbsp;<a href=\"https://www.tabletwise.com/medicine/probenecid\">probenecid</a>, which is used to treat&nbsp;<a href=\"https://www.tabletwise.com/health/gout\">gout</a>. This medicine reverses the effect of probenecid. Patients should avoid using both medicines together.</p>\n" +
            "\n" +
            "<p><strong>Read more:&nbsp;</strong><a href=\"https://www.tabletwise.com/loprin-tablet/interactions\">Interactions of Loprin by Severity</a></p>\n" +
            "\n" +
            "<h2>&nbsp;</h2>\n" +
            "\n" +
            "<h2>&nbsp;</h2>\n" +
            "\n" +
            "<ul>\n" +
            "</ul>\n" +
            "\n" +
            "<p>&nbsp;</p>\n" +
            "\n" +
            "<h2>&nbsp;</h2>\n" +
            "\n" +
            "<p>&nbsp;</p>\n
            """
        
        
       selectedProduct = getSavedProductObject(key: keyForSelectedProduct)
        htmlString = selectedProduct?.description ?? ""
        let htmlData = NSString(string: htmlString).data(using: String.Encoding.unicode.rawValue)

        let options = [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html]

        let attributedString = try! NSAttributedString(data: htmlData!, options: options, documentAttributes: nil)

        descriptionDetailTextView.attributedText = attributedString
    }
}
