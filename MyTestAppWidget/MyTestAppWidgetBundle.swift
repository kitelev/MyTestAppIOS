//
//  MyTestAppWidgetBundle.swift
//  MyTestAppWidget
//
//  Created by Андрей Кителёв on 23.11.2025.
//

import WidgetKit
import SwiftUI

@main
struct MyTestAppWidgetBundle: WidgetBundle {
    var body: some Widget {
        MyTestAppWidget()
        MyTestAppWidgetLiveActivity()
    }
}
