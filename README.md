# gwatch
Watch implementation

Published: https://apps.garmin.com/apps/619d861b-b12f-44ab-ad85-2c05f574aeaf

# Publishing

- change debug level to Warning in the resources/properties/properties.xml and save this file
>> <property id="MinimalDebugLevel" type="number">3</property>
- build an export
>> ```make clean-storage export```
- publish the new app using https://apps.garmin.com/en-US/developer/upload  and/or https://apps.garmin.com/apps/619d861b-b12f-44ab-ad85-2c05f574aeaf 
- publish a revised app using https://apps.garmin.com/en-US/developer/dashboard 


# Navigation

| Input type       | Action           |
|------------------|------------------|
| Swipe left/right | Switch views     |
| Back button      | Switch backwards |
| Select short     | Add message      |
| Select long      | Switch forward   |

**key mapping**
| Simulator / Watch Button | Delegate Method |
|--------------------------|-----------------|
| Click / Tap / Space	   | onSelect()      | 
| Start / Enter	         | onSelect()      | 
| Long Start	         | onSelectHold()  | 
| ESC / Back	         | onBack()        | 
| Long ESC	               | onBackHold()    | 
| Swipe	               | onSwipe()       | 

# Events

```text
User Input (Key/Swipe/Touch)
         ↓
   [Operating System]
         ↓
   [Connect IQ Runtime]
         ↓
   [Your App - MessengerApp]
         ↓
   [Active View Stack]
         ↓
   [Current InputDelegate]
         ↓
   [Event Handler Methods]
```

## View stack

```text
View Stack (top to bottom):
┌─────────────────────────┐
│  MessagesView           │ ← Active (receives events)
│  MessagesViewDelegate   │
├─────────────────────────┤
│  ClockView              │ ← Inactive (no events)
│  ClockViewDelegate      │
├─────────────────────────┤
│  AnalogView             │ ← Inactive (no events)
│  AnalogViewDelegate     │
└─────────────────────────┘
```

## Events

Input Event Types

**Physical Inputs**

- Keys: UP, DOWN, ENTER, ESC, START, LAP, etc.
- Touch: Swipe (UP, DOWN, LEFT, RIGHT), Tap, Long Press
- Rotation: Digital crown (on some devices)

**Event Types**

- PRESS_TYPE_DOWN - Button pressed down
- PRESS_TYPE_UP - Button released
- PRESS_TYPE_ACTION - Complete press (down + up)

## Event Routing

Event Routing Order

When an event occurs, the framework calls handler methods in priority order on the active delegate:

```text
User presses UP button
         ↓
Framework checks delegate methods in order:
         ↓
1. onKeyPressed()      ← If returns true, STOP
   ↓ (returns false)
2. onKey()             ← If returns true, STOP
   ↓ (returns false)
3. onPreviousPage()    ← If returns true, STOP
   ↓ (returns false)
4. Default behavior    ← Framework's fallback
```

## Event handler priority

**Button events**

```text
// Priority 1: Specific key press/release
function onKeyPressed(keyEvent) → true/false

function onKeyReleased(keyEvent) → true/false

// Priority 2: General key handler
function onKey(keyEvent) → true/false

// Priority 3: Specialized handlers (mapped to specific keys)
function onNextPage()         // UP button
function onPreviousPage()     // DOWN button
function onSelect()           // ENTER/START button
function onBack()             // BACK/ESC button
function onMenu()             // MENU button (some devices)
```

**Touch events**

```
// Priority 1: Touch events
function onTap(clickEvent) → true/false

function onSwipe(swipeEvent) → true/false

function onDrag(dragEvent) → true/false

function onFlick(flickEvent) → true/false

function onHold(clickEvent) → true/false

function onRelease(clickEvent) → true/false
```

**Event Flow Example**

**Scenario: User swipes left on MessagesView**
```
User swipes left
    ↓
┌─────────────────────────────────────┐
│ Connect IQ Framework                │
│ Detects swipe gesture               │
│ Direction: SWIPE_LEFT               │
└──────────────┬──────────────────────┘
               ↓
┌─────────────────────────────────────┐
│ Current View Stack                  │
│ Top: MessagesView                   │
│      MessagesViewDelegate           │ ← Active
└──────────────┬──────────────────────┘
               ↓
┌─────────────────────────────────────┐
│ MessagesViewDelegate                │
│ onSwipe(swipeEvent) called          │
│   direction = SWIPE_LEFT            │
└──────────────┬──────────────────────┘
               ↓
┌─────────────────────────────────────┐
│ Your Code in onSwipe()              │
│ if (direction == SWIPE_LEFT) {      │
│   WatchUi.switchToView(             │
│     new AnalogView(),               │
│     new AnalogViewDelegate()        │
│   );                                │
│   return true; ← Event handled!     │
│ }                                   │
└──────────────┬──────────────────────┘
               ↓
┌─────────────────────────────────────┐
│ WatchUi.switchToView()              │
│ 1. Remove MessagesView from stack   │
│ 2. Add AnalogView to stack          │
│ 3. AnalogView becomes active        │
└──────────────┬──────────────────────┘
               ↓
New View Stack:
┌─────────────────────────────────────┐
│ AnalogView           ← Now active   │
│ AnalogViewDelegate                  │
└─────────────────────────────────────┘
```

# Return Values Matter
Returning true:

"I handled this event"
Framework stops processing
Other handlers not called

Returning false:

"I didn't handle this event"
Framework continues to next handler
May trigger default behavior

# Current implementation

```text
MessengerApp
    ├── MessagesView + MessagesViewDelegate
    │   ├── onKey()           → Add/clear messages
    │   ├── onNextPage()      → Scroll up
    │   ├── onPreviousPage()  → Scroll down
    │   ├── onSwipe()         → Navigate views
    │   ├── onSelect()        → Go to AnalogView
    │   └── onBack()          → Go to ClockView
    │
    ├── ClockView + ClockViewDelegate
    │   ├── onSwipe()         → Navigate views
    │   ├── onSelect()        → Go to MessagesView
    │   └── onBack()          → Go to AnalogView
    │
    └── AnalogView + AnalogViewDelegate
        ├── onSwipe()         → Navigate views
        ├── onSelect()        → Go to ClockView
        └── onBack()          → Go to MessagesView
```