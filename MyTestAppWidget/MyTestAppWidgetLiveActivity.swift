//
//  MyTestAppWidgetLiveActivity.swift
//  MyTestAppWidget
//
//  Created by Андрей Кителёв on 23.11.2025.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct MyTestAppWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct MyTestAppWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: MyTestAppWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension MyTestAppWidgetAttributes {
    fileprivate static var preview: MyTestAppWidgetAttributes {
        MyTestAppWidgetAttributes(name: "World")
    }
}

extension MyTestAppWidgetAttributes.ContentState {
    fileprivate static var smiley: MyTestAppWidgetAttributes.ContentState {
        MyTestAppWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: MyTestAppWidgetAttributes.ContentState {
         MyTestAppWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: MyTestAppWidgetAttributes.preview) {
   MyTestAppWidgetLiveActivity()
} contentStates: {
    MyTestAppWidgetAttributes.ContentState.smiley
    MyTestAppWidgetAttributes.ContentState.starEyes
}
