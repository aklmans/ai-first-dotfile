#!/usr/bin/env bash
set -euo pipefail

open -g -a BetterTouchTool 2>/dev/null || open -a BetterTouchTool

/usr/bin/osascript <<'APPLESCRIPT'
on deleteTouchpadTrigger(triggerId)
  tell application "BetterTouchTool"
    try
      delete_triggers trigger_type "BTTTriggerTypeTouchpadAll" trigger_id triggerId trigger_app_bundle_identifier "BT.G"
    end try
  end tell
end deleteTouchpadTrigger

on addShellTouchpadTrigger(triggerId, triggerDescription, orderValue, commandText)
  set triggerJSON to "{\"BTTTriggerType\":" & (triggerId as text) & ",\"BTTTriggerTypeDescription\":\"" & triggerDescription & "\",\"BTTTriggerClass\":\"BTTTriggerTypeTouchpadAll\",\"BTTRequiredModifierKeys\":0,\"BTTEnabled\":1,\"BTTEnabled2\":1,\"BTTOrder\":" & (orderValue as text) & ",\"BTTGestureNotes\":\"" & triggerDescription & "\",\"BTTActionsToExecute\":[{\"BTTPredefinedActionType\":206,\"BTTPredefinedActionName\":\"Execute Shell Script  or  Task\",\"BTTShellTaskActionScript\":\"" & commandText & "\",\"BTTShellTaskActionConfig\":\"/bin/bash:::-c:::-:::\"}]}"
  tell application "BetterTouchTool" to add_new_trigger triggerJSON
end addShellTouchpadTrigger

on addBuiltinTouchpadTrigger(triggerId, triggerDescription, orderValue, actionType, actionName)
  set triggerJSON to "{\"BTTTriggerType\":" & (triggerId as text) & ",\"BTTTriggerTypeDescription\":\"" & triggerDescription & "\",\"BTTTriggerClass\":\"BTTTriggerTypeTouchpadAll\",\"BTTRequiredModifierKeys\":0,\"BTTEnabled\":1,\"BTTEnabled2\":1,\"BTTOrder\":" & (orderValue as text) & ",\"BTTGestureNotes\":\"" & triggerDescription & "\",\"BTTActionsToExecute\":[{\"BTTPredefinedActionType\":" & (actionType as text) & ",\"BTTPredefinedActionName\":\"" & actionName & "\"}]}"
  tell application "BetterTouchTool" to add_new_trigger triggerJSON
end addBuiltinTouchpadTrigger

set ownedTriggerIds to {100, 101, 102, 103, 105, 106, 107, 108}
repeat with triggerId in ownedTriggerIds
  my deleteTouchpadTrigger(triggerId)
end repeat

set pathPrefix to "export PATH=/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin; /bin/bash $HOME/.config/aerospace/focus-workspace-arrow.sh "

my addShellTouchpadTrigger(100, "3 Finger Swipe Left -> AeroSpace next workspace", 1, pathPrefix & "next")
my addShellTouchpadTrigger(101, "3 Finger Swipe Right -> AeroSpace previous workspace", 2, pathPrefix & "prev")
my addShellTouchpadTrigger(105, "4 Finger Swipe Left -> AeroSpace next workspace", 3, pathPrefix & "next")
my addShellTouchpadTrigger(106, "4 Finger Swipe Right -> AeroSpace previous workspace", 4, pathPrefix & "prev")

my addBuiltinTouchpadTrigger(102, "3 Finger Swipe Up -> Mission Control", 5, 7, "Mission Control")
my addBuiltinTouchpadTrigger(108, "4 Finger Swipe Up -> Mission Control", 6, 7, "Mission Control")
my addBuiltinTouchpadTrigger(103, "3 Finger Swipe Down -> App Expose", 7, 6, "Application Expose")
my addBuiltinTouchpadTrigger(107, "4 Finger Swipe Down -> App Expose", 8, 6, "Application Expose")
APPLESCRIPT
