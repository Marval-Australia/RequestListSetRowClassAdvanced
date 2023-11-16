# MSM Plugin :: RequestList Set Row Class

Adds a specific class to the entire request list row if a specific column in that row has a specific value. Rules are defined in the plugin configuration.


## Compatible Versions

| Plugin  | MSM                    | Updates, Comments
|---------|------------------------|-------------------------
| Any     | 15.x                   |
| Any     | 14.x                   |


## Configuration

Once the plugin has been installed you will need to configure the following settings within the plugin page:

*Plugin Configuration* : 	The plugin configuration rules stored in a JSON format. Each rule object should contain these three parameters specified:
+ Request Attribute Identifier - the ID of the request. This is displayed in the request attribute screen (Maintenance | Request | Attributes)
+ Request Attribute Value - the specific value to search for in the column
+ CSS Class Name - CSS class name to be applied to the row where the value was found. See the section "CSS Class Example Configuration" below for an example on how to configure this.
+ Database Connection String - The database connection string (can be omitted). This is retrieved from the local machine so should not be required however in cases where there is an issue with this, you can provide a string to use instead. See "Example Database Connection String" for an example


Style of classes used in the configuration must be defined in MSM Custom CSS specifications.

Please ensure that you have these system settings specified:
+ Include Custom Stylesheet = ON
+ Disable User Interface Plugins = OFF

## Notes on Configuration

If the attribute you are configuring is using Boolean, use 1 and 0 for true and false respectively.
Date attributes are not supported at this time.

## Example Database Connection String

An example database connection string could be as follows.
Data Source=servername;Initial Catalog=MarvalDBName;Integrated Security=False;User ID=MarvalMSMProd;Password=securepassword

## CSS Class Example Configuration

To configure the CSS Class, navigate to "Custom CSS" under Maintenance | System.
You can use the following CSS in here to turn the line light red.

```
.row-class-priority1 {
   background: #FFCCCB !important;
}
```

## Usage

Plugin is loaded up automatically when any request list is opened.

## Limitations



## Contributing

Any feedback is very welcome.