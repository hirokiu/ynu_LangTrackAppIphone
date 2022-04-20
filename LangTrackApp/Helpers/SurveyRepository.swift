//
//  SurveyRepository.swift
//  LangTrackApp
//
//  Created by Stephan Björck on 2020-02-05.
//  Copyright © 2020 Stephan Björck. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire
import Firebase



struct SurveyRepository {
    
    //sista nollan ska ändras till etta vid hämtning från dropbox
    //static let theUrl = "https://www.dropbox.com/s/qmvskzi4ejtg5ij/play_survey_json.txt?dl=1"
    //static let mockUrl = "https://e3777de6-509b-46a9-a996-ea2708cc0192.mock.pstmn.io/"
    //static let ltaUrl = "http://ht-lang-track.ht.lu.se/api/"
    //url on Firebase: "https://lta.ht.lu.se/api/"
    //stagingUrl on Firebase: "https://lta-staging.ht.lu.se/api/"
    
    
    static var idToken = ""
    static var deviceToken = ""{
        didSet{
            postDeviceToken()
        }
    }
    static var theUser: User?{
        willSet{
            if newValue?.userEmail != theUser?.userEmail || newValue?.userName != theUser?.userName{
                postDeviceToken()
            }
        }
    }
    static var localTimeZoneIdentifier = ""
    static var assignmentList: [Assignment] = []
    static var selectedAssignment: Assignment?
    static let tempuserId = "u123"
    static var userId = ""
    //static var ref: DatabaseReference!
    static let realtimeRef = Database.database().reference()
    static var useStagingServer = false
    
    static func setIdToken(token: String){
        self.idToken = token
    }
    
    static func emptyAssignmentsList(){
        assignmentList = []
    }
    
    static func setStagingServer(isActive: Bool){
        useStagingServer = isActive
        //selectedAssignment = nil
        //assignmentList = []
    }
    
    static func getUrl(completionhandler: @escaping (_ result: String?) -> Void){
        /*
         Getting the correct url from firebase realtime - prodUrl or stagingUrl
         */
        
        if useStagingServer {
            self.getStagingUrl { (theStagingUrl) in
                print("using staging server: \(theStagingUrl ?? "noValue")")
                completionhandler(theStagingUrl)
            }
        }else{
            self.getActiveUrl { (theUrl) in
                print("using active server \(theUrl ?? "noValue")")
                completionhandler(theUrl)
            }
        }
    }
    
    static func getActiveUrl(completionhandler: @escaping (_ result: String?) -> Void){
        realtimeRef.child("url").observeSingleEvent(of: .value, with: {(snapshot) in
            completionhandler(snapshot.value as? String ?? "")
        })
    }
    
    static func getStagingUrl(completionhandler: @escaping (_ result: String?) -> Void){
        realtimeRef.child("stagingUrl").observeSingleEvent(of: .value, with: {(snapshot) in
            completionhandler(snapshot.value as? String ?? "")
        })
    }
    
    static func checkDeviceToken(completionhandler: @escaping (_ result: String?) -> Void){
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instance ID: \(error)")
                completionhandler(nil)
            } else if let result = result {
                completionhandler(result.token)
            }
        }
    }
    
    //MARK: - Team and dynamic texts
    
    static func getContactInfo(complete: @escaping (_ result: [String:[String:String]]?) -> Void){
        realtimeRef.child("contactInfo").keepSynced(true)
        realtimeRef.child("contactInfo").observeSingleEvent(of: .value, with: {(snapshot) in
            let snapDict = snapshot.value
            if let userNamesDict = snapDict as? [Any]{
                var theResult : [String:[String:String]] = [:]
                for i in userNamesDict{
                    if let part = i as? [String:Any]{
                        var email = ""
                        var theTexts: [String:String] = [:]
                        for j in part{
                            if j.key == "email"{
                                email = j.value as? String ?? ""
                            }
                            if j.key == "text"{
                                if let textArray = j.value as? [String: String]{
                                    theTexts = textArray
                                }
                            }
                        }
                        theResult[email] = theTexts
                    }
                }
                complete(theResult)
            }
        }) { (error) in
            print("getContactInfo error: \(error)")
                complete(nil)
            
        }
    }
    
    static func getAboutText(complete: @escaping (_ result: [String:String]) -> Void){
        realtimeRef.child("about").keepSynced(true)
        realtimeRef.child("about").observeSingleEvent(of: .value, with: {(snapshot) in
            let snapDict = snapshot.value
            if let userNamesDict = snapDict as? [String:String]{
                complete(userNamesDict)
            }
        })
    }
    
    static func getTeamUsernames(complete: @escaping (_ result: [String:String]) -> Void){
        realtimeRef.child("admins").keepSynced(true)
        realtimeRef.child("admins").observeSingleEvent(of: .value, with: {(snapshot) in
            let snapDict = snapshot.value
            if let userNamesDict = snapDict as? [String:String]{
                complete(userNamesDict)
            }
        })
    }
    
    static func getTeamsText(complete: @escaping (_ result: [TeamMember]) -> Void){
        realtimeRef.child("team").keepSynced(true)
        realtimeRef.child("team").observeSingleEvent(of: .value, with: {(snapshot) in
            let snapDict = snapshot.value
            
            if let itemDict = snapDict as? [Any]{
                var temList : [TeamMember] = []
                for person in itemDict{
                    var listWithNames: [String:String] = [:]
                    var listWithDescr: [String:String] = [:]
                    if let personDict = person as? [String:Any]{
                        for language in personDict{
                            if let thelanguage = language.value as? [String:Any]{
                                var name = ""
                                var description = ""
                                for item in thelanguage{
                                    if item.key == "name"{
                                        name = item.value as? String ?? ""
                                    }
                                    if item.key == "description"{
                                        description = item.value as? String ?? ""
                                    }
                                }
                                listWithNames[language.key] = name
                                listWithDescr[language.key] = description
                            }
                        }
                    }
                    if listWithNames.first?.value ?? "" != ""{
                        temList.append(TeamMember(name: listWithNames,description: listWithDescr))
                    }
                }
                complete(temList)
            }
        })
    }
    
    
    //MARK: - Device & other
    
    static func apiIsAlive(completionHandler: @escaping (_ result: Bool) -> Void){
        getUrl { (theUrl) in
            if let theUrl = theUrl{
                if theUrl != ""{
                    let pingUrl = "\(theUrl)ping"
                    let request = NSMutableURLRequest(url: URL(string: pingUrl)!)
                    request.setValue(idToken, forHTTPHeaderField: "token")
                    let session = URLSession.shared
                    request.httpMethod = "GET"
                    let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
                        if let httpResponse = response as? HTTPURLResponse {
                            if httpResponse.statusCode == 200{
                                completionHandler(true)
                            }else{
                                completionHandler(false)
                            }
                        }else{
                            completionHandler(false)
                        }
                        return
                    })
                    task.resume()
                }
            }
        }
    }
    
    static func postDeviceToken(){
        print("postDeviceToken 1")
        if userId != "" && deviceToken != ""{
            let vNumber = UIDevice.current.systemVersion
            print("vNumber: \(vNumber)")
            getUrl { (theUrl) in
                if let theUrl = theUrl{
                    if theUrl != ""{
                        let version = UIApplication.appVersion ?? "noVersionNumber"
                        let param = [
                            "timezone": localTimeZoneIdentifier,
                            "deviceToken": deviceToken,
                            "versionNumber": version,
                            "os": "iOS \(vNumber)"
                        ]
                        
                        let deviceTokenUrl = "\(theUrl)users/\(userId)"
                        let request = NSMutableURLRequest(url: URL(string: deviceTokenUrl)!)
                        request.setValue("application/json", forHTTPHeaderField: "Accept")
                        request.setValue(idToken, forHTTPHeaderField: "token")
                        
                        do {
                            request.httpBody = try JSONSerialization.data(withJSONObject: param, options: .prettyPrinted)
                        } catch let error {
                            print(error.localizedDescription)
                        }
                        
                        let session = URLSession.shared
                        request.httpMethod = "PUT"
                        
                        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                        request.addValue("application/json", forHTTPHeaderField: "Accept")
                        
                        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
                            if(error != nil){
                                print("postDeviceToken ERROR, task = session.dataTask: \(error!.localizedDescription)")
                                return
                            }else{
                                if let httpResponse = response as? HTTPURLResponse {
                                    print("postDeviceToken response statusCode: \(httpResponse.statusCode)")
                                }
                            }
                        })
                        task.resume()
                    }
                }
                
            }
        }
    }
    
    //MARK: - Survey
    
    static func postAnswer(answerDict: [Int: Answer]){
        if userId != ""{
            var answers = [AnswerBody]()
            for answer in answerDict.values{
                var body = AnswerBody()
                body.index = answer.index
                body.type = answer.type
                switch answer.type {
                case "likert":
                    body.intValue = answer.likertAnswer
                case "single":
                    body.intValue = answer.singleMultipleAnswer
                case "blanks":
                    body.intValue = answer.fillBlankAnswer
                case Type.sliderScale.rawValue:
                    body.intValue = answer.sliderScaleAnswer
                case "multi":
                    body.multiValue = answer.multipleChoiceAnswer
                case "open":
                    body.stringValue = answer.openEndedAnswer
                case "duration":
                    body.intValue = answer.timeDurationAnswer
                default:
                    print("answersDict, no match in switch")
                }
                if body.index != -99{
                    answers.append(body)
                }
            }
            let theBody = ["answers": answers]
            if selectedAssignment?.id ?? "" != ""{
                let headers: HTTPHeaders = [
                    "token": idToken,
                    "Content-Type":"application/json"
                ]
                getUrl { (theUrl) in
                    if let theUrl = theUrl{
                        if theUrl != ""{
                            let answerUrl = "\(theUrl)users/\(userId)/assignments/\(selectedAssignment!.id)/datasets"
                            let req = AF.request(answerUrl,
                                       method: .post,
                                       parameters: theBody,
                                       encoder: JSONParameterEncoder.default,
                                       headers: headers)
                            /*
                             //print out request
                            req.cURLDescription { (curl) in
                               print("CURL \(curl)")
                            }*/
                            req.response { response in
                            }
                        }
                    }
                }
                
            }
        }
    }
    
    static func surveyOpened(){
        
        if selectedAssignment != nil{
            if selectedAssignment!.id != ""{
                getUrl { (theUrl) in
                    if let theUrl = theUrl{
                        if theUrl != ""{
                            //https://lta.ht.lu.se/api/assignments/(selectedAssignment!.id)/open
                            let deviceTokenUrl = "\(theUrl)assignments/\(selectedAssignment!.id)/open"
                            let request = NSMutableURLRequest(url: URL(string: deviceTokenUrl)!)
                            request.setValue("application/json", forHTTPHeaderField: "Accept")
                            request.setValue(idToken, forHTTPHeaderField: "token")
                            
                            let session = URLSession.shared
                            request.httpMethod = "POST"
                            
                            let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
                                if(error != nil){
                                    print("ERROR, task = session.dataTask: \(error!.localizedDescription)")
                                    return
                                }else{
                                    if let httpResponse = response as? HTTPURLResponse {
                                        print("surveyOpened response statusCode: \(httpResponse.statusCode)")
                                    }
                                }
                            })
                            task.resume()
                        }
                    }
                }
            }
        }
    }
    
    static func getSurveys( completionhandler: @escaping (_ result: [Assignment]?) -> Void){
        getUrl { (theUrl) in
            if let theUrl = theUrl{
                if theUrl != ""{
                    print("getSurveys, userId: \(userId)")
                    if userId != ""{
                        //http://ht-lang-track.ht.lu.se/api/users/alicia/assignments
                        let assignmentsTokenUrl = "\(theUrl)users/\(userId)/assignments"
                        let request = NSMutableURLRequest(url: URL(string: assignmentsTokenUrl)!)
                        
                        // Set HTTP Request Header
                        request.setValue("application/json", forHTTPHeaderField: "Accept")
                        request.setValue(idToken, forHTTPHeaderField: "token")
                        
                        let session = URLSession.shared
                        request.httpMethod = "GET"
                        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData//to refresh...
                        
                        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
                            if(error != nil){
                                print("ERROR, task = session.dataTask: \(error!.localizedDescription)")
                                completionhandler(nil)
                                return
                            }
                            /*do {
                             // Read all HTTP Response Headers
                             if let response = response as? HTTPURLResponse {
                             print("All headers: \(response.allHeaderFields)")
                             // Read a specific HTTP Response Header by name
                             print("Specific header: \(response.value(forHTTPHeaderField: "Content-Type") ?? " header not found")")
                             }
                             }*/
                            if data != nil{
                                let listWithAssignments = createAssignmentsFromData(data: data!)
                                if listWithAssignments != nil{
                                    for assignment in listWithAssignments!{
                                        for question in assignment.survey.questions{
                                            if question.index == 0{
                                                question.previous = 0
                                                question.next = question.index + 1
                                            }else if question.index < assignment.survey.questions.count - 1{
                                                question.next = question.index + 1
                                                question.previous = question.index - 1
                                            }else{
                                                question.next = 0
                                                question.previous = question.index - 1
                                            }
                                        }
                                    }
                                }
                                if listWithAssignments != nil{
                                    assignmentList = listWithAssignments!
                                }
                            }
                            
                            completionhandler(assignmentList)
                        })
                        task.resume()
                    }
                }
            }
        }
        
    }
    
    
    //MARK: - helper func
    
    static func sortAssignmentList(theList : [Assignment]) -> [Assignment]{
        let now = Date()
        //if the assignment is active and the dataset is empty
        var activeList = theList.filter {$0.dataset == nil && DateParser.getDate(dateString: $0.expiry) ?? now > now}
        
        //if the assignment is not active or the dataset exists
        var unActiveList = theList.filter {$0.dataset != nil || DateParser.getDate(dateString: $0.expiry) ?? now < now}
        activeList.sort {DateParser.getDate(dateString: $0.published) ?? Date() > DateParser.getDate(dateString: $1.published) ?? Date()}
        unActiveList.sort {DateParser.getDate(dateString: $0.published) ?? Date() > DateParser.getDate(dateString: $1.published) ?? Date()}
        var finallist = [Assignment]()
        finallist.append(contentsOf: activeList)
        finallist.append(contentsOf: unActiveList)
        
        return finallist
    }
    
    private static func createAssignmentsFromData(data: Data) -> [Assignment]?{
        var returnValue = [Assignment]()
        do {
            let json = try JSON(data: data)
            for (_,assignmentJson):(String, JSON) in json {
                var tempAssignment = Assignment()
                for (key,postJson):(String, JSON) in assignmentJson{
                    if key == "_id"{
                        tempAssignment.id = postJson.stringValue
                    }
                    if key == "userId"{
                        tempAssignment.userId = postJson.stringValue
                    }
                    if key == "createdAt"{
                        tempAssignment.createdAt = postJson.stringValue
                    }
                    if key == "updatedAt"{
                        tempAssignment.updatedAt = postJson.stringValue
                    }
                    if key == "expireAt"{
                        tempAssignment.expiry = postJson.stringValue
                    }
                    if key == "publishAt"{
                        tempAssignment.published = postJson.stringValue
                    }
                    if key == "survey"{
                        if let surveyDict = postJson.dictionaryObject{
                            
                            if let updatedAt = surveyDict["updatedAt"] as? String{
                                tempAssignment.survey.updatedAt = updatedAt
                            }
                            if let createdAt = surveyDict["createdAt"] as? String{
                                tempAssignment.survey.createdAt = createdAt
                            }
                            if let id = surveyDict["name"] as? String{
                                tempAssignment.survey.name = id
                            }
                            if let id = surveyDict["id"] as? String{//TODO: remove
                                tempAssignment.survey.id = id
                            }
                            if let title = surveyDict["title"] as? String{
                                tempAssignment.survey.title = title
                            }
                            if let published = surveyDict["publishAt"] as? String{
                                tempAssignment.survey.published = published
                            }
                            if let expiry = surveyDict["expireAt"] as? String{
                                tempAssignment.survey.expiry = expiry
                            }
                            if let questionsDict = surveyDict["questions"] as? [Any]{
                                for question in questionsDict{
                                    let tempQuestion = Question()
                                    var values: [String]?
                                    if let post = question as? [String: Any]{
                                        
                                        var index = -99
                                        var type = ""
                                        var description = ""
                                        var title = ""
                                        var text = ""
                                        var likertMax = ""
                                        var likertMin = ""
                                        for questionPost in post{
                                            if questionPost.key == "index"{
                                                index = questionPost.value as? Int ?? -99
                                            }
                                            if questionPost.key == "type"{
                                                type = questionPost.value as? String ?? ""
                                            }
                                            if questionPost.key == "description"{
                                                description = questionPost.value as? String ?? ""
                                            }
                                            if questionPost.key == "maxAnnotation"{
                                                likertMax = questionPost.value as? String ?? ""
                                            }
                                            if questionPost.key == "minAnnotation"{
                                                likertMin = questionPost.value as? String ?? ""
                                            }
                                            if questionPost.key == "title"{
                                                title = questionPost.value as? String ?? ""
                                            }
                                            if questionPost.key == "text"{
                                                text = questionPost.value as? String ?? ""
                                            }
                                            if questionPost.key == "values"{
                                                if let valuesArray = questionPost.value as? [String]{
                                                    values = valuesArray
                                                }
                                            }
                                            if questionPost.key == "skip"{
                                                if let skipDict = questionPost.value as? [String:Int]{
                                                    let tempSkip = SkipLogic()
                                                    for i in skipDict{
                                                        if i.key == "goto"{
                                                            tempSkip.goto = i.value
                                                        }
                                                        if i.key == "ifChosen"{
                                                            tempSkip.ifChosen = i.value
                                                        }
                                                    }
                                                    tempQuestion.skip = tempSkip
                                                }
                                            }
                                            if questionPost.key == "includeIf"{
                                                if let skipDict = questionPost.value as? [String:Int]{
                                                    let tempIncludeIf = IncludeIf()
                                                    for i in skipDict{
                                                        if i.key == "ifIndex"{
                                                            tempIncludeIf.ifIndex = i.value
                                                        }
                                                        if i.key == "ifValue"{
                                                            tempIncludeIf.ifValue = i.value
                                                        }
                                                    }
                                                    tempQuestion.includeIf = tempIncludeIf
                                                }
                                            }
                                        }
                                        tempQuestion.index = index
                                        tempQuestion.type = type
                                        tempQuestion.description = description
                                        tempQuestion.title = title
                                        tempQuestion.text = text
                                        tempQuestion.likertMax = likertMax
                                        tempQuestion.likertMin = likertMin
                                    }
                                    if values != nil{
                                        switch tempQuestion.type {
                                        case "single":
                                            tempQuestion.singleMultipleAnswers = values
                                        case "multi":
                                            tempQuestion.multipleChoisesAnswers = values
                                        case "blanks":
                                            tempQuestion.fillBlanksChoises = values
                                        default:
                                            1 == 1//not using default...
                                        }
                                    }
                                    tempAssignment.survey.questions.append(tempQuestion)
                                }
                            }
                        }
                    }
                    if key == "dataset"{
                        let setDict = postJson.dictionaryObject
                        let tempDataSet : Dataset?
                        if setDict != nil{
                            tempDataSet = Dataset()
                            
                            if let updatedAt = setDict!["updatedAt"] as? String{
                                tempDataSet!.updatedAt = updatedAt
                            }
                            if let createdAt = setDict!["createdAt"] as? String{
                                tempDataSet!.createdAt = createdAt
                            }
                            let answersDict = setDict!["answers"] as? [Any]
                            if answersDict != nil{
                                var tempAnswers = [Answer]()
                                for post in answersDict!{
                                    if let answer = post as? [String: Any]{
                                        var index = 0
                                        var type = ""
                                        var multiValue: [Int]?
                                        var intValue: Int?
                                        var stringValue: String?
                                        for answerPost in answer{
                                            if answerPost.key == "index"{
                                                index = answerPost.value as? Int ?? 0
                                            }
                                            if answerPost.key == "type"{
                                                type = answerPost.value as? String ?? ""
                                            }
                                            if answerPost.key == "multiValue"{
                                                multiValue = answerPost.value as? [Int]
                                            }
                                            if answerPost.key == "intValue"{
                                                intValue = answerPost.value as? Int
                                            }
                                            if answerPost.key == "stringValue"{
                                                stringValue = answerPost.value as? String
                                            }
                                        }
                                        switch type {
                                        case Type.sliderScale.rawValue:
                                            tempAnswers.append(Answer(type: Type.sliderScale.rawValue,
                                                                      index: index,
                                                                      likertAnswer: nil,
                                                                      fillBlankAnswer: nil,
                                                                      multipleChoiceAnswer: nil,
                                                                      singleMultipleAnswer: nil,
                                                                      openEndedAnswer: nil,
                                                                      timeDurationAnswer: nil,
                                                                      sliderScaleAnswer: intValue))
                                        case "likert":
                                            tempAnswers.append(Answer(type: "likert",
                                                                      index: index,
                                                                      likertAnswer: intValue,
                                                                      fillBlankAnswer: nil,
                                                                      multipleChoiceAnswer: nil,
                                                                      singleMultipleAnswer: nil,
                                                                      openEndedAnswer: nil,
                                                                      timeDurationAnswer: nil))
                                        case "single":
                                            tempAnswers.append(Answer(type: "single",
                                                                      index: index,
                                                                      likertAnswer: nil,
                                                                      fillBlankAnswer: nil,
                                                                      multipleChoiceAnswer: nil,
                                                                      singleMultipleAnswer: intValue,
                                                                      openEndedAnswer: nil,
                                                                      timeDurationAnswer: nil))
                                        case "multi":
                                            tempAnswers.append(Answer(type: "multi",
                                                                      index: index,
                                                                      likertAnswer: nil,
                                                                      fillBlankAnswer: nil,
                                                                      multipleChoiceAnswer: multiValue,
                                                                      singleMultipleAnswer: nil,
                                                                      openEndedAnswer: nil,
                                                                      timeDurationAnswer: nil))
                                        case "blanks":
                                            tempAnswers.append(Answer(type: "blanks",
                                                                      index: index,
                                                                      likertAnswer: nil,
                                                                      fillBlankAnswer: intValue,
                                                                      multipleChoiceAnswer: nil,
                                                                      singleMultipleAnswer: nil,
                                                                      openEndedAnswer: nil,
                                                                      timeDurationAnswer: nil))
                                        case "open":
                                            tempAnswers.append(Answer(type: "open",
                                                                      index: index,
                                                                      likertAnswer: nil,
                                                                      fillBlankAnswer: nil,
                                                                      multipleChoiceAnswer: nil,
                                                                      singleMultipleAnswer: nil,
                                                                      openEndedAnswer: stringValue,
                                                                      timeDurationAnswer: nil))
                                        case "duration":
                                            tempAnswers.append(Answer(type: "duration",
                                                                      index: index,
                                                                      likertAnswer: nil,
                                                                      fillBlankAnswer: nil,
                                                                      multipleChoiceAnswer: nil,
                                                                      singleMultipleAnswer: nil,
                                                                      openEndedAnswer: nil,
                                                                      timeDurationAnswer: intValue))
                                        default:
                                            print("answersDict, no match in switch")
                                        }
                                    }
                                }
                                tempDataSet!.answers = tempAnswers
                            }
                            if tempDataSet != nil{
                                tempAssignment.dataset = tempDataSet
                            }
                        }
                    }
                }
                tempAssignment.survey.questions.sort(by: { $0.index < $1.index})
                returnValue.append(tempAssignment)
            }
        }catch  {
            print("no json")
        }
        if returnValue.count > 0{
            returnValue = sortAssignmentList(theList: returnValue)
            return returnValue
        }else{
            return nil
        }
    }
}
