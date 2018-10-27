require_relative '../app/checking_methods'

describe "contains_expected_keys?(data, *expected_keys)" do
  subject { contains_expected_keys?(data, *expected_keys) }
  let(:data) { {"name" => "John", "weight" => 60, "growth" => 170} }

  context "when the data contains all expected keys" do
    context "in the order they are listed" do
      let(:expected_keys) { ["name", "weight", "growth"] }

      it { should be true}
    end
    
    context "in mixed order" do
      let(:expected_keys) { ["growth", "name", "weight"] }

      it { should be true }
    end
  end

  context "when the data does not contain all expected keys" do
    let(:expected_keys) { ["degree", "growth"] }

    it { should be false }
  end

  context "when there is no expected keys" do
    let(:expected_keys) { [] }

    it { should be true }
  end
end

describe "filter_keys(data, *expected_keys)" do
  subject { filter_keys(data, *expected_keys) }
  let(:data) { {"name" => "John", "weight" => 60, "growth" => 170} }

  context "when the data consist only expected keys" do
    let(:copy) { {"name" => "John", "weight" => 60, "growth" => 170} }
    let(:expected_keys) { ["name", "weight", "growth"] }

    it { should eql copy }
  end

  context "when the data include excess keys" do
    let(:expected_keys) { ["name", "growth"] }

    it { should_not include "weight" }
    it { should include "name" }
    it { should include "growth" }
  end

  context "when the data does not contain any expected keys" do
    let(:expected_keys) { ["madness", "tries"] }

    it { should be {} }
  end
end

describe "correct_type?(key, value)" do
  subject { correct_type?(key, value) }

  context "when the key is id" do
    let(:key) { "id" }

    context "and the value is an integer" do
      let(:value) { 1 }

      it { should be true }
    end

    context "and the value is not an integer" do
      let(:value) { 5.7 }

      it { should be false }
    end
  end

  context "when the key is name" do
    let(:key) { "name" }

    context "and the value is a string" do
      let(:value) { "Bob" }

      it { should be true }
    end

    context "and the value is not a string" do
      let(:value) { 1 }

      it { should be false }
    end
  end

  context "when the key is madness" do
    let(:key) { "madness" }

    context "and the value is an integer" do
      let(:value) { 1 }

      it { should be true }
    end

    context "and the value is not an integer" do
      let(:value) { 5.7 }

      it { should be false }
    end
  end

  context "when the key is tries" do
    let(:key) { "tries" }

    context "and the value is an integer" do
      let(:value) { 1 }

      it { should be true }
    end

    context "and the value is not an integer" do
      let(:value) { 5.7 }

      it { should be false }
    end
  end

  context "when the key is power" do
    let(:key) { "power" }

    context "and the value is an integer" do
      let(:value) { 1 }

      it { should be true }
    end

    context "and the value is not an integer" do
      let(:value) { 5.7 }

      it { should be false }
    end
  end
end

describe "corresponds_to_constraint?(key, value)" do
  subject { corresponds_to_constraint?(key, value) }
  
  context "when the key is id" do
    let(:key) { "id" }

    context "and the value is positive" do
      let(:value) { 1 }

      it { should be true }
    end

    context "and the value is equal to 0" do
      let(:value) { 0 }

      it { should be false }
    end

    context "and the value is negative" do
      let(:value) { -1 }

      it { should be false }
    end
  end

  context "when the key is name" do
    let(:key) { "name" }

    context "and the value is not an empty string" do
      let(:value) { "Bob" }

      it { should be true }
    end

    context "and the value is an empty string" do
      let(:value) { "" }

      it { should be false }
    end
  end

  context "when the key is madness" do
    let(:key) { "madness" }

    context "and the value is positive" do
      let(:value) { 1 }

      it { should be true }
    end

    context "and the value is equal to 0" do
      let(:value) { 0 }

      it { should be true }
    end

    context "and the value is negative" do
      let(:value) { -1 }

      it { should be false }
    end
  end

  context "when the key is tries" do
    let(:key) { "tries" }

    context "and the value is positive" do
      let(:value) { 1 }

      it { should be true }
    end

    context "and the value is equal to 0" do
      let(:value) { 0 }

      it { should be true }
    end

    context "and the value is negative" do
      let(:value) { -1 }

      it { should be false }
    end
  end

  context "when the key is power" do
    let(:key) { "power" }

    context "and the value is positive" do
      let(:value) { 1 }

      it { should be true }
    end

    context "and the value is equal to 0" do
      let(:value) { 0 }

      it { should be true }
    end

    context "and the value is negative" do
      let(:value) { -1 }

      it { should be false }
    end
  end
end

describe "is_correct_data?(data, *expected_keys)" do
  subject { is_correct_data?(data, *expected_keys) }

  context "when data satisfies all conditions (i.e. is correct)" do
    let(:expected_keys) { ["name", "tries"] }

    context "and does not contain excess" do
      let(:data) { {"name" => "Jill", "tries" => 0} }

      it { should be true }
    end

    context "and contains an excess" do
      context "of correct type" do
        let(:data) { {"name" => "Jill", "madness" => 5, "tries" => 0} }

        it { should be true }
      end

      context "of incorrect type" do
        let(:data) { {"name" => "Jill", "madness" => -1, "tries" => 0} }

        it { should be true }
      end
    end
  end

  context "when data does not contain expected keys" do
    let(:data) { {"name" => "Jill", "madness" => 5, "tries" => 0} }
    let(:expected_keys) { ["id"] }

    it { should be false }
  end

  context "when data contains incorrect type values" do
    let(:expected_keys) { ["name", "madness"] }

    context "because it is expected string instead of integer" do
      let(:data) { {"name" => 0, "madness" => 5} }

      it { should be false }
    end

    context "because it is expected integer instead of string" do
      let(:data) { {"name" => "Bob", "madness" => "crazy"} }

      it { should be false }
    end

    context "because it is expected integer instead of float" do
      let(:data) { {"name" => "Bob", "madness" => 50.0} }

      it { should be false }
    end
  end

  context "when values do not corresponds to constraints" do
    let(:expected_keys) { ["id", "name", "power"] }

    context "because name is empty string" do
      let(:data) { {"id" => 1, "name" => "", "power" => 0} }

      it { should be false }
    end

    context "because id is equal to 0" do
      let(:data) { {"id" => 0, "name" => "Bob", "power" => 0} }

      it { should be false }
    end

    context "because power is negative" do
      let(:data) { {"id" => 1, "name" => "Bob", "power" => -1} }

      it { should be false }
    end
  end
end
