# These methods are for checking correctness of request body.
# Here data is the parsed JSON request body, i.e. a hash.

def contains_expected_keys?(data, *expected_keys)
  expected_keys.each do |expected_key|
    return false until data.keys.include? expected_key
  end
  return true
end

# Get rid of all keys that are not expected (required)
def filter_keys(data, *expected_keys)
  excess_keys = data.keys - expected_keys
  excess_keys.each do |key|
    data.delete(key)
  end
  return data
end

def correct_type?(key, value)
  case
  when key == 'id'
    return value.is_a? Integer
  when key == 'name'
    return value.is_a? String
  when key == 'madness'
    return value.is_a? Integer
  when key == 'tries'
    return value.is_a? Integer
  when key == 'power'
    return value.is_a? Integer
  end
end

def corresponds_to_constraint?(key, value)
  case
  when key == 'id'
    return value > 0
  when key == 'name'
    return value.length > 0
  when key == 'madness'
    return value >= 0
  when key == 'tries'
    return value >= 0
  when key == 'power'
    return value >= 0
  end
end

# Check if actual data extracted from request body is correct, i.e. it
# contains all expected pairs (key: value), all required values are of the
# correct type and corresponds to database constraint
def is_correct_data?(data, *expected_keys)
  return false until contains_expected_keys?(data, *expected_keys)
  filter_keys(data, *expected_keys)
  data.each do |key, value|
    return false until correct_type?(key, value)
  end
  data.each do |key, value|
    return false until corresponds_to_constraint?(key, value)
  end
  return true
end
