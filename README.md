# Gradient App Bar

Love the material AppBar? Do you want to add more color to the appbar? Here's a gradientAppBar.

It works just like the normal AppBar. Also with actions, back buttons, titles. So it's just your normal AppBar, but with a twist!

## Screenshots

![image](https://user-images.githubusercontent.com/7083755/43866104-e9bc98ea-9b64-11e8-9115-b2deec915dbd.png)
![image](https://user-images.githubusercontent.com/7083755/43866237-4f8e6a5e-9b65-11e8-8adf-2514a9b1e10c.png)


## Getting Started
This fork should solve the problem with new versions of Flutter since 1.26.

1. Depend on it by adding this to your pubspec.yaml file: 
```
gradient_app_bar:
    git: https://github.com/Alex-A4/GradientAppBar
```yaml

2. Import it: ```import 'package:gradient_app_bar/gradient_app_bar.dart'```

3. Replace your current AppBar (In the scaffold) to GradientAppBar. 


```
appBar: GradientAppBar(
    title: Text('Flutter'),
    gradient: LinearGradient(colors: [Colors.blue, Colors.purple, Colors.red])
  ),
```


