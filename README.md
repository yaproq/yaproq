# Yaproq - A templating language for Swift

## Template examples
### `/templates/base.html`
```html
<!doctype html>
<html lang="en">
    <head>
        <title>{% block title %}{{ title }}{% endblock %}</title>
        {% block css %}
            <link href="/public/css/base.min.css" rel="stylesheet" />
        {% endblock %}
    </head>
    <body>
        {% block body %}{% endblock %}
        {% block js %}
            <script src="/public/js/base.min.js"></script>
        {% endblock %}
    </body>
</html>
```

### `/templates/posts.html`
```html
{% extend "base.html" %}

{% block css %}
    {% @super %}
    <link href="/public/css/posts.min.css" rel="stylesheet" />
{% endblock %}

{% block js %}
    {% @super %}
    <script src="/public/js/posts.min.js"></script>
{% endblock %}

{% block body %}
    <h2>All posts</h2>
    {% for post in posts %}
        <p>{{ post.title }}</p>
    {% endfor %}
{% endblock %}
```

## Features
- Custom delimiters
    - Defaults
        - `{{` `}}` to output an expression
        - `{%` `%}` to execute a statement
        - `{#` `#}` to add a comment
- Loading templates
- Rendering templates
- Error handling
- Template inheritance
- Expressions
    - Assignment (e.g. `a = 1`, `b = "some text"`, etc)
    - Binary (e.g. `a + b`, `a > b`, etc)
    - Grouping (e.g. `(a + b) * c`)
    - Literal (e.g. `1`, `2.0`, `"some text"`, `true`, `false`, etc)
    - Logical (e.g. `&&` and `||`)
    - Ternary (e.g. `a > b ? "a is greater" : "a is not greater"`)
    - Unary (e.g. `!a` and `-b`)
    - Variable (e.g. `var a = 1`, `var b = 2.0`, `var c = "some text"`, etc)
- Statements
    - `block`
    - `extend`
    - `for` loop
    - `if`, `elseif`, and `else` conditions
    - `include`
    - `@super`
    - `while` loop
- An array and dictionary declaration inside a template file (under development)
- Built-in filters (under development)
    - Array
    - Date
    - Dictionary
    - String
    - etc
- Custom filters (under development)
- Caching (under development)
- Logging and debugging (under development)
- Documentation (under development)
- Test coverage (under development)
    

## Installation
### Swift
Download and install [Swift](https://swift.org/download)

### Swift Package
```shell
mkdir MyApp
cd MyApp
swift package init --type executable // Creates an executable app named "MyApp"
```

### Package.swift
```swift
// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "MyApp",
    dependencies: [
        .package(name: "yaproq", url: "https://github.com/yaproq/yaproq.git", .branch("master"))
    ],
    targets: [
        .target(name: "MyApp", dependencies: [
            .product(name: "Yaproq", package: "yaproq"),
        ]),
        .testTarget(name: "MyAppTests", dependencies: [
            .target(name: "MyApp")
        ])
    ]
)
```

### Build
```shell
swift build -c release
```

## Usage

### Custom delimiters
```swift
import Yaproq

do {
    let templating = Yaproq(
        configuration: try .init(
            delimiters: [
                .comment("{^", "^}"),
                .output("{$", "$}"),
                .statement("{@", "@}")
            ]
        )
    )
} catch {
    print(error)
}
```

### Loading templates
#### Name
```swift
import Yaproq

let templating = Yaproq(configuration: .init(directoryPath: "/templates"))

do {
    let templateName = "base.html"
    let template = try templating.loadTemplate(named: templateName)
    print(template)
} catch {
    print(error)
}
```

#### Path
```swift
import Yaproq

let templating = Yaproq()

do {
    let templatePath = "/templates/base.html"
    let template = try templating.loadTemplate(at: templatePath)
    print(template)
} catch {
    print(error)
}
```

### Rendering templates
#### Name
```swift
import Yaproq

let templating = Yaproq(configuration: .init(directoryPath: "/templates"))

do {
    let templateName = "base.html"
    let context: [String: Encodable] = ["title": "My Blog"]
    let output = try templating.renderTemplate(named: templateName, in: context)
    print(output)
} catch {
    print(error)
}
```

#### Path
```swift
import Yaproq

let templating = Yaproq()

do {
    let templatePath = "/templates/base.html"
    let context: [String: Encodable] = ["title": "My Blog"]
    let output = try templating.renderTemplate(at: templatePath, in: context)
    print(output)
} catch {
    print(error)
}
```

#### Template
```swift
import Yaproq

let templating = Yaproq()

do {
    let templatePath = "/templates/base.html"
    let template = try templating.loadTemplate(at: templatePath)
    let context: [String: Encodable] = ["title": "My Blog"]
    let output = try templating.renderTemplate(template, in: context)
    print(output)
} catch {
    print(error)
}
```


### Error handling
```swift
import Yaproq

let templating = Yaproq()

do {
    let templatePath = "/templates/base.html"
    let context: [String: Encodable] = ["title": "My Blog"]
    let output = try templating.renderTemplate(at: templatePath, in: context)
    print(output)
} catch {
    if let error = error as? YaproqError { // YaproqError occurs when there is a problem with a custom configuration provided, for example, due to invalid or non-unique delimiters provided for each delimiter type.
        print(error)
    } else if let error = error as? TemplateError { // TemplateError occurs when there is a problem with a template file itself, for example, the templating engine can't find and load it.
        print(error)
    } else if let error = error as? SyntaxError { // SyntaxError occurs when an existing feature is used incorrectly and can't be parsed.
        print(error)
    } else if let error = error as? RuntimeError { // RuntimeError occurs when the templating engine can't interpret an expression or statement because an output is semantically incorrect.
        print(error)
    } else {
        print("Unknown error: \(error)")
    }
}
```

### Template inheritance
```swift
struct Post: Encodable {
    var title: String
}
```

```swift
import Yaproq

let templating = Yaproq(configuration: .init(directoryPath: "/templates"))

do {
    let templateName = "posts.html"
    let context: [String: Encodable] = [
        "title": "Posts",
        "posts": [
            Post(title: "Post 1"),
            Post(title: "Post 2"),
            Post(title: "Post 2")
        ]
    ]
    let output = try templating.renderTemplate(named: templateName, in: context)
    print(output)
} catch {
    print(error)
}
```

### Run
```shell
swift run
```

### Tests
```shell
swift test --enable-test-discovery --sanitize=thread
```
