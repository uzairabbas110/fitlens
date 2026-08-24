/**
 * Strict Input Schema Validator Middleware
 * Validates request body, query, and params against strict types, lengths, formats, and allowed fields.
 * Rejects invalid inputs with HTTP 400 and detailed structured error messages.
 */

// Common regex patterns
const PATTERNS = {
  EMAIL: /^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+$/,
  SAFE_FILENAME: /^[a-zA-Z0-9_\-\. ]{1,255}$/,
  BASE64_DATA: /^(?:data:image\/(?:jpeg|png|webp|heic|heif);base64,)?[A-Za-z0-9+/=]+$/,
  CITY: /^[a-zA-Z0-9\s,.'\-()]{1,100}$/,
  // Password: > 8 characters (min 9), at least 1 uppercase, 1 lowercase, 1 digit, 1 special character
  STRONG_PASSWORD: /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?~` ]).{9,}$/,
};

/**
 * Validates a single value against a field schema definition
 * Returns an error string or null if valid
 */
function validateField(fieldName, value, rule, context = {}) {
  const isPresent = value !== undefined && value !== null;

  // 1. Required Check
  if (rule.required && (!isPresent || (typeof value === 'string' && value.trim() === ''))) {
    return rule.requiredMessage || `"${fieldName}" is required and cannot be empty.`;
  }

  // If optional and not present, valid
  if (!isPresent) {
    return null;
  }

  // 2. Type Check
  const expectedType = rule.type;
  if (expectedType) {
    if (expectedType === 'string') {
      if (typeof value !== 'string') {
        return `"${fieldName}" must be of type string (received ${typeof value}).`;
      }
    } else if (expectedType === 'number') {
      if (typeof value !== 'number' || Number.isNaN(value)) {
        return `"${fieldName}" must be a valid finite number.`;
      }
    } else if (expectedType === 'numeric') {
      // Allows numbers or numeric strings (e.g. from query params)
      const num = Number(value);
      if (typeof value !== 'number' && typeof value !== 'string') {
        return `"${fieldName}" must be a numeric value.`;
      }
      if (Number.isNaN(num) || !Number.isFinite(num)) {
        return `"${fieldName}" must be a valid numeric number.`;
      }
    } else if (expectedType === 'boolean') {
      if (typeof value !== 'boolean') {
        return `"${fieldName}" must be a boolean (true/false).`;
      }
    } else if (expectedType === 'array') {
      if (!Array.isArray(value)) {
        return `"${fieldName}" must be an array.`;
      }
    } else if (expectedType === 'object') {
      if (typeof value !== 'object' || Array.isArray(value) || value === null) {
        return `"${fieldName}" must be a JSON object.`;
      }
    }
  }

  // 3. String Length & Pattern Checks
  if (typeof value === 'string') {
    const trimmed = rule.trim !== false ? value.trim() : value;

    if (rule.minLength !== undefined && trimmed.length < rule.minLength) {
      return (
        rule.minLengthMessage ||
        `"${fieldName}" length must be at least ${rule.minLength} characters (received ${trimmed.length}).`
      );
    }

    if (rule.maxLength !== undefined && trimmed.length > rule.maxLength) {
      return (
        rule.maxLengthMessage ||
        `"${fieldName}" length must not exceed ${rule.maxLength} characters (received ${trimmed.length}).`
      );
    }

    if (rule.pattern && !rule.pattern.test(trimmed)) {
      return rule.patternMessage || `"${fieldName}" format is invalid.`;
    }
  }

  // 4. Numeric Range Checks
  if (typeof value === 'number' || rule.type === 'numeric') {
    const num = Number(value);
    if (rule.min !== undefined && num < rule.min) {
      return rule.minMessage || `"${fieldName}" must be greater than or equal to ${rule.min} (received ${num}).`;
    }
    if (rule.max !== undefined && num > rule.max) {
      return rule.maxMessage || `"${fieldName}" must be less than or equal to ${rule.max} (received ${num}).`;
    }
  }

  // 5. Enum Checks
  if (rule.enum && Array.isArray(rule.enum)) {
    if (!rule.enum.includes(value)) {
      return `"${fieldName}" must be one of: [${rule.enum.join(', ')}] (received "${value}").`;
    }
  }

  // 6. Array Items Checks
  if (Array.isArray(value)) {
    if (rule.minItems !== undefined && value.length < rule.minItems) {
      return `"${fieldName}" must contain at least ${rule.minItems} item(s).`;
    }
    if (rule.maxItems !== undefined && value.length > rule.maxItems) {
      return `"${fieldName}" must not exceed ${rule.maxItems} item(s).`;
    }
    if (rule.items) {
      for (let i = 0; i < value.length; i++) {
        const itemError = validateField(`${fieldName}[${i}]`, value[i], rule.items, context);
        if (itemError) return itemError;
      }
    }
  }

  // 7. Nested Object Properties Checks
  if (rule.type === 'object' && rule.properties && typeof value === 'object' && value !== null) {
    const objErrors = validateObject(value, rule.properties, rule.allowUnknown === true);
    if (objErrors.length > 0) {
      return objErrors[0].message;
    }
  }

  // 8. Custom Validator Function
  if (typeof rule.custom === 'function') {
    const customResult = rule.custom(value, context);
    if (customResult) {
      return customResult;
    }
  }

  return null;
}

/**
 * Validates an entire object against a property schema map
 */
function validateObject(data = {}, schemaProperties = {}, allowUnknown = false) {
  const errors = [];
  const knownKeys = new Set(Object.keys(schemaProperties));

  // Check unknown properties
  if (!allowUnknown && typeof data === 'object' && data !== null) {
    for (const key of Object.keys(data)) {
      if (!knownKeys.has(key)) {
        errors.push({
          field: key,
          message: `Unknown field "${key}" is not allowed.`,
        });
      }
    }
  }

  // Check defined schema rules
  for (const [key, rule] of Object.entries(schemaProperties)) {
    const val = data ? data[key] : undefined;
    const errorMsg = validateField(key, val, rule, { data });
    if (errorMsg) {
      errors.push({
        field: key,
        message: errorMsg,
      });
    }
  }

  return errors;
}

/**
 * Express Middleware Factory
 * Accepts schema definitions for body, query, and params
 *
 * Example:
 * router.post('/login', validate({ body: loginSchema }), handler);
 */
function validate(schemas = {}) {
  return function validationMiddleware(req, res, next) {
    const errors = [];

    // 1. Validate Body Schema
    if (schemas.body) {
      const bodyData = req.body || {};
      const schemaRules = schemas.body.properties || schemas.body;
      const allowUnknown = schemas.body.allowUnknown === true;

      // Custom root object validator (e.g. conditional rules across multiple fields)
      if (typeof schemas.body.validateRoot === 'function') {
        const rootErr = schemas.body.validateRoot(bodyData, req);
        if (rootErr) {
          errors.push(typeof rootErr === 'string' ? { field: 'body', message: rootErr } : rootErr);
        }
      }

      const bodyErrors = validateObject(bodyData, schemaRules, allowUnknown);
      errors.push(...bodyErrors);
    }

    // 2. Validate Query Schema
    if (schemas.query) {
      const queryData = req.query || {};
      const schemaRules = schemas.query.properties || schemas.query;
      const allowUnknown = schemas.query.allowUnknown === true;

      if (typeof schemas.query.validateRoot === 'function') {
        const rootErr = schemas.query.validateRoot(queryData, req);
        if (rootErr) {
          errors.push(typeof rootErr === 'string' ? { field: 'query', message: rootErr } : rootErr);
        }
      }

      const queryErrors = validateObject(queryData, schemaRules, allowUnknown);
      errors.push(...queryErrors);
    }

    // 3. Validate Params Schema
    if (schemas.params) {
      const paramsData = req.params || {};
      const schemaRules = schemas.params.properties || schemas.params;
      const allowUnknown = schemas.params.allowUnknown === true;

      const paramsErrors = validateObject(paramsData, schemaRules, allowUnknown);
      errors.push(...paramsErrors);
    }

    // If validation failed, reject immediately with HTTP 400 Bad Request
    if (errors.length > 0) {
      return res.status(400).json({
        error: 'Validation Error',
        message: 'Invalid request input. Please correct the highlighted errors.',
        details: errors,
      });
    }

    next();
  };
}

module.exports = {
  validate,
  validateField,
  validateObject,
  PATTERNS,
};
