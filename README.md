![Yaproq](https://yaproq.dev/logo.png)
# Yaproq - A templating language for Swift

[![Swift](https://img.shields.io/badge/swift-5.3-brightgreen.svg)](https://swift.org/download/#releases) [![MIT License](https://img.shields.io/badge/license-MIT-brightgreen.svg)](https://github.com/yaproq/yaproq/blob/master/LICENSE/) [![Actions Status](https://github.com/yaproq/yaproq/workflows/development/badge.svg)](https://github.com/yaproq/yaproq/actions) [![Codacy Badge](https://app.codacy.com/project/badge/Grade/6cc4920a71e848a588a827f14bbafe8e)](https://www.codacy.com/gh/yaproq/yaproq/dashboard?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=yaproq/yaproq&amp;utm_campaign=Badge_Grade) [![codecov](https://codecov.io/gh/yaproq/yaproq/branch/master/graph/badge.svg?token=LvV6AiCSna)](https://codecov.io/gh/yaproq/yaproq) [![Contributing](https://img.shields.io/badge/contributing-guide-brightgreen.svg)](https://github.com/yaproq/yaproq/blob/master/CONTRIBUTING.md)

Yaproq is a templating language powered by fast, secure, and powerful Swift language and uses a similar syntax to the Django, Jinja, and Twig templating languages but more Swifty.

## Contents
* [Features](#features)
* [Todo](#todo)
* [Installation](#installation)
    * [Swift](#swift)
    * [Swift Package](#swift-package)
    * [Package.swift](#packageswift)
    * [Build](#build)
    * [Run](#run)
* [Usage](#usage)
    * [Comments](#comments)
    * [Variables](#variables)
    * [Math expressions](#math-expressions)
    * [Control structures](#control-structures)
    * [Including other templates](#including-other-templates)
    * [Template inheritance](#template-inheritance)
    * [Custom delimiters](#custom-delimiters)
    * [Loading templates](#loading-templates)
    * [Rendering templates](#rendering-templates)
    * [Error handling](#error-handling)
* [Tests](#tests)

## Features
* Custom delimiters
    * Defaults
        * `{{` `}}` to output an expression
        * `{%` `%}` to execute a statement
        * `{#` `#}` to add a comment
* Loading templates
* Rendering templates
* Error handling
* Template inheritance
* Expressions
    * Assignment (e.g. `a = 1`, `b = "some text"`, etc)
    * Binary (e.g. `a + b`, `a > b`, etc)
    * Grouping (e.g. `(a + b) * c`)
    * Literal (e.g. `1`, `2.0`, `"some text"`, `true`, `false`, etc)
    * Logical (e.g. `&&` and `||`)
    * Range (e.g. `0..<3` and `1...4`)
    * Ternary (e.g. `a > b ? "a is greater" : "a is not greater"`)
    * Unary (e.g. `!a` and `-b`)
    * Variable (e.g. `var a = 1`, `var b = 2.0`, `var c = "some text"`, etc)
* Statements
    * `block`
    * `extend`
    * `for` loop
    * `if`, `elseif`, and `else` conditions
    * `include`
    * `super`
    * `while` loop
* Memory caching with `NSCache`

## Todo
* A simple array, dictionary, and tuple declaration inside a template file
* Custom filters
* Logging and debugging

## Installation
### Swift
Download and install [Swift](https://swift.org/download)

### Swift Package
```shell
mkdir MyApp
cd MyApp
swift package init --type executable // Creates an executable app named "MyApp"
```

#### Package.swift
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
### Comments
```html
{# A single-line comment #}
{#
    A
    multi-line
    comment
#}
```

### Variables
```html
{% var int = 1 %}
{% var float = 2.0 %}
{% var string = "some text" %}
{% var booleanTrue = true %}
{% var booleanFalse = false %}
{% var range = 0..<3 %}
{% var closedRange = 1...4 %}
{% var item0 = array[0] %}
{% var value = dictionary[key] %}
```

### Math expressions
```
{% var five = 5.0 %}
{% var four = 4 %}
{% var three = 3 %}
{% var two = 2.0 %}
{% var seven = 7.0 %}
{% var six = 6 %}
{% var one = 1.0 %}
{% var result = five * four / (three + two) - seven % six ^ one %}
{{ result }}
```

### Control structures
#### If, elseif, and else
```
{% var number = 1 %}

{% if number == 0 %}
    Equal to 0
{% elseif number >= 1 %}
    Greater than or equal to 1
{% elseif number > 2 %}
    Greater than 2
{% elseif number <= 3 %}
    Less than or equal to 3
{% elseif number < 4 %}
    Less than 4
{% else %}
    Greater than or equal to 4
{% endif %}
```

#### For loop
```
{% for item in array %}
    {{ item }}
{% endfor %}
```

```
{% for index, item in array %}
    {{ index }}, {{ item }}
{% endfor %}
```

```
{% for key, value in dictionary %}
    {{ key }}, {{ value }}
{% endfor %}
```

```
{% for number in 0..<3 %}
    {{ number }}
{% endfor %}
```

```
{% for number in 1...4 %}
    {{ number }}
{% endfor %}
```

#### While loop
```
{% var number = 0 %}
{% var maxNumber = 3 %}

{% while number < maxNumber %}
    {{ number }}
    {% number += 1 %}
{% endwhile %}
```

#### Blocks
```html
<!doctype html>
<html lang="en">
    <head>
        <title>{% block title %}{% endblock %}</title>
    </head>
    <body>
        {% block body %}
            {% block header %}{% endblock %}
            <div class="container">
                {% block content %}{% endblock %}
            </div>
            {% block footer %}{% endblock %}
        {% endblock %}
    </body>
</html>
```

### Including other templates
```html
{% block body %}
    {% include "header.html" %}
    <div class="container">
        {% block content %}{% endblock %}
    </div>
    {% include "footer.html" %}
{% endblock %}
```

### Template inheritance
#### /templates/base.html
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

#### /templates/posts.html
```html
{% extend "base.html" %}

{% block css %}
    {% super %}
    <link href="/public/css/posts.min.css" rel="stylesheet" />
{% endblock %}

{% block js %}
    {% super %}
    <script src="/public/js/posts.min.js"></script>
{% endblock %}

{% block body %}
    <h2>All posts</h2>
    {% for post in posts %}
        <p>{{ post.title }}</p>
    {% endfor %}
{% endblock %}
```

```swift
import Yaproq

struct Post: Encodable {
    var title: String
}

let templating = Yaproq(configuration: .init(directories: Set(arrayLiteral: "/templates")))

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
    let result = try templating.renderTemplate(named: templateName, in: context)
    print(result)
} catch {
    print(error)
}
```

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

let templating = Yaproq(configuration: .init(directories: Set(arrayLiteral: "/templates")))

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

let templating = Yaproq(configuration: .init(directories: Set(arrayLiteral: "/templates")))

do {
    let templateName = "base.html"
    let context: [String: Encodable] = ["title": "My Blog"]
    let result = try templating.renderTemplate(named: templateName, in: context)
    print(result)
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
    let result = try templating.renderTemplate(at: templatePath, in: context)
    print(result)
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
    let result = try templating.renderTemplate(template, in: context)
    print(result)
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
    let result = try templating.renderTemplate(at: templatePath, in: context)
    print(result)
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

## Tests
```shell
swift test --enable-test-discovery --sanitize=thread
```
