//
//  CloudCode.swift
//  x
//
//  Created by Diego Silva on 10/26/15.
//  Copyright © 2015 SudoCRUD. All rights reserved.
//

import UIKit

class CloudCode: NSObject {

    
    // LOCATIONS
    /*
        Get all user locations
    
    */
    
    
    /*
        Check if the user has at least one valid location
    
    PFCloud.callFunctionInBackground("userHasLocation", withParameters: [
    "userId": user.objectId!
    ]) {
    (answer, error) in
    
    if (error == nil){
    if let result:Int = answer as? Int{
    
    switch result{
    case 0:
    print("user has at least one location.")
    self.dbh.initializeGlobalVariables(nil)
    
    case 1:
    print("user doens't have a location.")
    self.infoWindow("Nenhum ambiente foi encontrado para a sua conta, realize o cadastro.", title: "Aviso", vc: self)
    
    case 2:
    print("operational error.")
    self.infoWindow("Houve um erro ao verificar os locais do usuário atual", title: "Aviso", vc: self)
    
    default:
    print("unknow error.")
    self.infoWindow("Erro desconhecido. Falha ao encontrar dados do usuário", title: "Erro operacional", vc: self)
    }
    
    }else{
    print("problems converting cloud query result")
    self.infoWindow("Falha ao acessar dados no servidor", title: "Erro operacional", vc: self)
    }
    }else{
    print("\nerror: \(error)")
    self.infoWindow("Falha ao acessar dados no servidor", title: "Erro operacional", vc: self)
    }
    }
    */
    
    
    /*
        Check if a location is valid
    
    let locationId = "ZY5drwkW2k"
    let locationId = ""
    PFCloud.callFunctionInBackground("isLocationKeyValid", withParameters: ["locationId": locationId]) {
    (answer, error) in
    
    if (error == nil){
    if let result:Bool = answer as? Bool{
    if(result){
    print("Location key is valid.")
    }else{
    print("Location key is invalid.")
    }
    }else{
    print("problems converting cloud query result")
    }
    }else{
    print("\nerror: \(error)")
    }
    }*/
    
    
    /*
        Get all available locations
    
    PFCloud.callFunctionInBackground("getAvailableLocations", withParameters: ["objectId": "bxsoFJU46b"]) {
    (locationIds, error) in
    
    if (error == nil){
    if let locs:Array<String> = locationIds as? Array<String> {
    print("\navailable location ids: \n\(locs)")
    }else{
    print("problems converting results into array of locations.")
    }
    }else{
    print("\nerror: \(error)")
    }
    }*/
    
    
    
    
    /*
    PFCloud.callFunctionInBackground("adminRegistration", withParameters: [
    "user"       : userId,
    "location"   : locationId,
    "withDevice" : true,
    "deviceId"   : deviceId
    ]){
    (opCode, error) in
    
    if (error == nil){
    if let result = opCode as? Int{
    self.processRegistrationResult(result)
    }else{
    print("problems converting cloud query result")
    self.infoWindow("Erro ao ler dados do servidor", title: "Erro operacional", vc: self)
    }
    }else{
    print("\nerror: \(error)")
    self.infoWindow("Falha na conexão", title: "Erro operacional", vc: self)
    self.lockScreen(self.lockView, actionIndicator: self.spinner, lockIt: false)
    }
    }
    */
    
    
    
    /*
    PFCloud.callFunctionInBackground("adminRegistration",
    withParameters: [
    "user"       : userId,
    "location"   : locationId,
    "withDevice" : false,
    "deviceId"   : "undefined"
    ]){
    (opCode, error) in
    
    if (error == nil){
    if let result = opCode as? Int{
    self.processRegistrationResult(result)
    }else{
    print("problems converting cloud query result")
    self.infoWindow("Erro ao ler dados do servidor", title: "Erro operacional", vc: self)
    }
    }else{
    print("\nerror: \(error)")
    self.infoWindow("Falha na conexão", title: "Erro operacional", vc: self)
    }
    }
    */
    
    
    
    
    // SESSIONS
    /*
        Delete invalid sessions in the background
    
    PFCloud.callFunctionInBackground("deleteNullSessions", withParameters: ["objectId": "bxsoFJU46b"]) {
    (msg, error) in
    
    if (error == nil){
    print("\nresult: \(msg)")
    }else{
    print("\nerror: \(error)")
    }
    }*/
    
    
}
