const { PATTERNS } = require('../middleware/validator');

const currentWeatherSchema = {
  allowUnknown: false,
  validateRoot(query) {
    const hasCity = query && typeof query.city === 'string' && query.city.trim().length > 0;
    const hasLat = query && (query.lat !== undefined && query.lat !== null && query.lat !== '');
    const hasLon = query && (query.lon !== undefined && query.lon !== null && query.lon !== '');

    if (!hasCity && (!hasLat || !hasLon)) {
      return 'You must provide either a "city" name OR both "lat" and "lon" coordinates.';
    }
    return null;
  },
  properties: {
    city: {
      type: 'string',
      required: false,
      minLength: 1,
      maxLength: 100,
      pattern: PATTERNS.CITY,
      patternMessage: '"city" name must contain only letters, numbers, spaces, commas, periods, hyphens, or parentheses.',
    },
    lat: {
      type: 'numeric',
      required: false,
      min: -90,
      max: 90,
      minMessage: '"lat" (latitude) must be between -90 and 90 degrees.',
      maxMessage: '"lat" (latitude) must be between -90 and 90 degrees.',
    },
    lon: {
      type: 'numeric',
      required: false,
      min: -180,
      max: 180,
      minMessage: '"lon" (longitude) must be between -180 and 180 degrees.',
      maxMessage: '"lon" (longitude) must be between -180 and 180 degrees.',
    },
  },
};

module.exports = {
  currentWeatherSchema,
};
