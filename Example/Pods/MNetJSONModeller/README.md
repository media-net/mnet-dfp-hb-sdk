# MNetJSONModeller

A small and feature-ful json modelling library in Objective-C. 

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

mnet-json-modeller is available through the mnet private [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
# Add the source repo for the private repository.
source 'https://github.com/media-net/mnet-pod-specs.git'
source 'https://github.com/CocoaPods/Specs.git'

pod 'MNetJSONModeller'
```

## Usage

### Parsing json-str to given models

To parse json strings to a model, use the `[MNJMManager fromJSONStr:toObj:]` static method.

Suppose you'd want to map this json-string into an object-model - 
```json
{
  "string_data": "this is a string",
  "number_data": 12.3,
  "bool_data": true
}
```

Then, you'd need to create that model as it is, and simply implement the `MNJMMapperProtocol`.

This model is represented here - 

```ObjC
/// A model for illustrating how the json-modeller works.
/// Notice that this implements a MNJMMapperProtocol.
@interface SimpleModel : NSObject <MNJMMapperProtocol>
@property (nonatomic) NSString *stringData;
@property (nonatomic) NSNumber *numberData;
@property (nonatomic) MNJMBoolean *boolData;
@end

/// Empty implementation
@implementation SimpleModel
@end
```

NOTE: Only objects can be used in models, and no parsing support for non-objects like `NSUInteger`, `BOOL` is provided. For numbers, use `NSNumber` and for `BOOL`, we've provided a special object `MNJMBoolean`. (You can use NSNumber for `BOOL` as well)

Then, using `[MNJMManager fromJSONStr:toObj:]`, you'd map the string to the `SimpleModel` object.

```ObjC
// Sample input string
NSString *ipStr = @"{\"string_data\": \"this is a string\",\"number_data\": 12.3,\"bool_data\": true}";

// Create an instance of the model
SimpleModel *model  = [SimpleModel new];

// Call the static method `[MNJMManager fromJSONStr:toObj:]`
[MNJMManager fromJSONStr:ipStr toObj:model];

// That's it!
```

And that's it! Notice that the snake-cased keys in the json are mapped to the camel-cased keys in the model (`string_data`-> `stringData`).

#### Customize the model key names 

If you'd rather prefer having different keys than the actual json, that's also possible! 

You'll just have to implement `propertyKeyMap` method in the `MNJMMapperProtocol`.

Let's take an example. Suppose in the model above, we'd like to use `booleanData` as the property-name, instead of `boolData`. Then, in your `SimpleModel` implementation, add the `propertyKeyMap` method, which maps the json key `bool_data` to `booleanData` - 

```ObjC
@interface SimpleModel : NSObject <MNJMMapperProtocol>
// ... the same-old properties
@property (nonatomic) MNJMBoolean *booleanData;
@end

@implementation SimpleModel

- (NSDictionary<NSString *, NSString *> *)propertyKeyMap{
    return @{
             @"booleanData": @"bool_data"
        };
}

@end
```

NOTE: All property names that begin with `__` will be skipped by the parser. So if you need to have properties that are public but need not be part of any json-conversion processes, just prefix the property names with `__`.

#### Supporting collections - `NSArray` and `NSDictionary`

If your json contains arrays and maps, you can specify the types of the maps in the `collectionDetailsMap` method in the `MNJMMapperProtocol`. We try to guess the type of the object, defaulting to NSString, but accurate results will only be obtained by specifying the type of contents of the collection ( Even after specifying the array type, like `NSArray<NSString *> *myList` does not help, because of [type-erasure](https://en.wikipedia.org/wiki/Type_erasure)).

Enough talk, here's an compound example. 

Suppose we'd like to model a json like this - 
```json
{
  "title_message": "compound model",
  "compound_obj": {
    "string_data": "Inside the map with key - key1",
    "number_data": 12.3,
    "bool_data": true
  },
  "compound_map": {
    "key1": {
      "string_data": "Inside the map with key - key1",
      "number_data": 12.3,
      "bool_data": true
    }
  },
  "compound_list": [
    {
      "string_data": "First item of the list!",
      "bool_data": true
    },
    {
      "string_data": "Second item of list!",
      "bool_data": false
    }
  ]
}
```
 This is similar to the `simpleModel`, except that it's repeated in multiple places. 

 This compound model now looks like this - 
 ```ObjC
@interface CompoundModel : NSObject <MNJMMapperProtocol>
@property (nonatomic) NSString *titleMessage;
@property (nonatomic) SimpleModel *compoundObj;
@property (nonatomic) NSDictionary *compoundMap;
@property (nonatomic) NSArray *compoundList;
@end

@implementation CompoundModel

- (NSDictionary<NSString *,MNJMCollectionsInfo *> *)collectionDetailsMap{
    return @{
             @"compoundMap": [MNJMCollectionsInfo instanceOfDictionaryWithKeyType:[NSString class]
                                                                     andValueType:[SimpleModel class]],
             @"compoundList": [MNJMCollectionsInfo instanceOfArrayWithClassType:[SimpleModel class]]
             };
}

@end
 ```

Note that we'd had to specify the class names using `MNJMCollectionsInfo`, which allows for adding types for arrays and dictionaries.

The actual parsing is similar to the example above - 
```ObjC
CompoundModel *model  = [CompoundModel new];
[MNJMManager fromJSONStr:ipStr toObj:model];
```


#### Mapping contents without modification into a `NSDictionary`

Suppose one of the content in your keys, be mapped as-is, in the form of a  `NSDictionary`. Then, specify that key name in the `- (NSArray <NSString *> *)directMapForKeys;` method in the `MNJMMapperProtocol`. Doing this will also prevent the content keys to be converted from snake-case to camel-case.

### Parsing model-objects to json-str

To convert the models into json, use the `[MNJMManager toJSONStr:]` static method.

Following from the previous examples, the json-mapping for the `CompoundModel` 
mentioned above would be - 

```ObjC
NSString *userEntriesJson = [MNJMManager toJSONStr:compoundModelObj];
```

### Inherit properties from base-classes automatically!

If you have a model that inherits from another model, then the properties of the base-model are automatically parsed!
Just make sure that the `-propertyKeyMap`, `-collectionDetailsMap` and `-directMapForKeys` methods in the sub-class, call their respective super-class methods and return collective response, since these methods will be called only once, for the sub-classes.


### Miscellaneous

Take a look at `MNJMManager.h` file for other helpful methods.

## Author

gnithin, nithin.g@directi.com
