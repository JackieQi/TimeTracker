//
//  Store.swift
//  TimeTracker
//
//  Created by Sam Ritchie on 19/01/2016.
//  Copyright © 2016 Realm Inc. All rights reserved.
//

import Foundation
import RealmSwift

class Project: Object {
    dynamic var name: String = ""
    let activities = List<Activity>()
}

class Activity: Object {
    dynamic var startDate: Date?
    dynamic var endDate: Date?
}

extension Project {
    var elapsedTime: TimeInterval {
        return activities.reduce(0) { time, activity in
            guard let start = activity.startDate,
                let end = activity.endDate else { return time }
            return time + end.timeIntervalSince(start)
        }
    }
    
    var currentActivity: Activity? {
        return activities.filter("endDate == nil").first
    }
}

// MARK: Application/View state
extension Realm {
    var projects: Results<Project> {
        return objects(Project.self)
    }
}

// MARK: Actions
extension Realm {
    func addProject(_ name: String) {
        do {
            try write {
                let project = Project()
                project.name = name
                add(project)
            }
        } catch {
            print("Add Project action failed: \(error)")
        }
   }
    
    func deleteProject(_ project: Project) {
        do {
            try write {
                delete(project.activities)
                delete(project)
            }
        } catch {
            print("Delete Project action failed: \(error)")
        }
    }
    
    func startActivity(_ project: Project, startDate: Date) {
        do {
            try write {
                let act = Activity()
                act.startDate = startDate
                project.activities.append(act)
            }
        } catch {
            print("Start Activity action failed: \(error)")
        }
    }
    
    func endActivity(_ project: Project, endDate: Date) {
        guard let activity = project.currentActivity else { return }
        
        do {
            try write {
                activity.endDate = endDate
            }
        } catch {
            print("End Activity action failed: \(error)")
        }
     }

}

let store = try! Realm()
