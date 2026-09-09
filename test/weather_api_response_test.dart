import 'package:flutter_test/flutter_test.dart';
import 'package:farmer_ai_assistant/model/weather_insight_model.dart';
import 'package:farmer_ai_assistant/ui/weather_advice/weather_advice_viewmodel.dart';

void main() {
  test('FieldConditionsModel parses backend snake_case weather JSON', () {
    final model = FieldConditionsModel.fromJson({
      'temp_fahrenheit': 0,
      'location_label': 'string',
      'humidity_percent': 0,
      'wind_mph': 0,
      'wind_direction': 'string',
      'condition_description': '',
    });

    expect(model.tempFahrenheit, 0);
    expect(model.locationLabel, 'string');
    expect(model.humidityPercent, 0);
    expect(model.windMph, 0);
    expect(model.windDirection, 'string');
    expect(model.conditionDescription, '');
  });

  test('FieldConditionsModel parses nested backend data wrapper', () {
    final model = FieldConditionsModel.fromJson({
      'data': {
        'temp_fahrenheit': 26,
        'location_label': 'Islamabad',
        'humidity_percent': 52,
        'wind_mph': 10,
        'wind_direction': 'NW',
        'condition_description': 'Clear and mild weather',
      },
    });

    expect(model.tempFahrenheit, 26);
    expect(model.locationLabel, 'Islamabad');
    expect(model.humidityPercent, 52);
    expect(model.windMph, 10);
    expect(model.windDirection, 'NW');
    expect(model.conditionDescription, 'Clear and mild weather');
  });

  test('FieldConditionsModel supports nested conditions payload with decimals', () {
    final model = FieldConditionsModel.fromJson({
      'conditions': {
        'temp_fahrenheit': 87.82,
        'location_label': 'Lahore',
        'humidity_percent': 74,
        'wind_mph': 3.44,
        'wind_direction': 'SSW',
        'condition_description': 'few clouds',
      },
    });

    expect(model.tempFahrenheit, 87.82);
    expect(model.locationLabel, 'Lahore');
    expect(model.humidityPercent, 74);
    expect(model.windMph, 3.44);
    expect(model.windDirection, 'SSW');
    expect(model.conditionDescription, 'few clouds');
  });
}
