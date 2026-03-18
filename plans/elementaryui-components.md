# elementary-views

# ElementaryViews (import name)

# Phase 0 - Create Package

create elementary-views swift package in the root of PSProject
target name should be ElementaryViews, so its "import ElementaryViews"
add following as dependencies
* Elementary
* ElementaryUI
* Reactivity


# Phase 1 - Create Macros

i have copied the @View macro from elementaryui, which fixes the issue with struct marked public
* PSProjectConfigWasm/Sources/LayoutMacros/ViewMacro.swift

but this time call it ViewMacros instead of LayoutMacros, but still bundle the Layout.swift with it
* PSProjectConfigWasm/Sources/LayoutMacros/LayoutMacros.swift

views that should be public available from the package now needs to use this 

```
@attached(memberAttribute)
public macro PublicView() = #externalMacro(module: "LayoutMacros", type: "ViewMacro")
```
(module: should be "ViewMacros" instead ofc)

PublicViews is located in 
* PSProjectConfigWasm/Sources/WebApp/Macros/LayoutMacros.swift

and whole file should be copied to ElementaryViews, but renamed ViewMacros.swift

# Phase 2 - Move Existing Reuseable Components from PSProjectConfigWasm

move all the base components to ElementaryViews, and add ElementaryViews as deps for PSProjectConfigWasm ofcourse.

# Phase 3 - Add more UI elements concepts fron SwiftUI in ElementaryViews

add SwiftUI like structures where it makes sense 

the generic struct issue fix

```
@PublicView
struct Button<Label: View>  {
    
    let label: Label
    let onClick: () -> Void
    
    typealias Tag = HTMLTag.button // important and allows us to specific example Label: View
    // @View/@PublicView expects first generic arg to be Tag, and doesnt play nicely with this
    // Generic struct, but by setting Tag inside the struct we now allowed to add own Generics 
    // to the struct, and should allow more SwiftUI alike structs
    
    // init it with view cloussure
    init(@HTMLBuilder label: ()->Label, onClick: @escaping () -> Void) {
        self.label = label()
        self.onClick = onClick
    }
    
    // init it with fixed View type
    init(label: Label, onClick: @escaping () -> Void) {
        self.label = label
        self.onClick = onClick
    }
    
    // init with StringProtocol since View is kinda just "String"
    init(text: Label, onClick: @escaping () -> Void) where Label: StringProtocol {
        self.label = text
        self.onClick = onClick
    }
    
    var body: some View {
        button { label }
            .onClick(onClick)
    }
}
```

we can make View functions like this 

```
extension View {
    
    consuming func frame(_ css: CSSTextSize) -> some View<Tag> {
        self // self modified with sizing
    }
    
    consuming func _button(_ onClick: @escaping ()->Void) -> some View {
        Button(label: self, onClick: onClick)
    }
}
```

dont know if Elementary has Html/ViewModifier concept or if needed to make at all for the view functions ..

there is a research folder with the whole SwiftUI api, also OpenSwiftUI have been added in case you need some example of how to implement NavigationStack ect..

* ElementaryViews/research/OpenSwiftUI
* ElementaryViews/research/SwiftUI-api
