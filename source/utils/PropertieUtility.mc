using Toybox.Application.Properties;
using Toybox.Lang;

class PropertieUtility
{
    private static var _instance as PropertieUtility?;

    // Private constructor
    private function initialize() {}

    // Get singleton instance
    static function getInstance() as PropertieUtility
    {
        if (_instance == null) {
            _instance = new PropertieUtility();
        }
        return _instance;
    }

    // Helper function to safely get number properties
    public function getPropertyNumber(propertyKey, defaultValue)
    {
        var value = Properties.getValue(propertyKey);

        if (value == null) {
            return defaultValue;
        }

        // Handle both String and Number types
        if (value instanceof Lang.String) {
            return value.toNumber();
        } else if (value instanceof Lang.Number) {
            return value;
        } else {
            return defaultValue;
        }
    }

    public function getPropertyBoolean(propertyKey, defaultValue)
    {
        var value = Properties.getValue(propertyKey);

        if (value == null) {
            return defaultValue;
        }

        // Handle both String and Number types
        if (value instanceof Lang.Boolean) {
            return value;
        } else if (value instanceof Lang.String) {
            return value.equals("true");
        } else {
            return defaultValue;
        }
    }
}

function getPropertieUtility() as PropertieUtility
{
    return PropertieUtility.getInstance();
}
