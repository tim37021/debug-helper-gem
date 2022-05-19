RSpec.describe DebugHelper do
  it "has a version number" do
    expect(DebugHelper::Common::VERSION).not_to be nil
  end

  let(:my_class) {
    Class.new do
      attr_reader :original_called
      class << self
        attr_reader :original_called
        def original
          @original_called = true
        end
      end

      def original
        @original_called = true
      end
    end
  }

  it "hooks method" do
    called = false
    described_class.hook_method(my_class, :original) do |mth, args, &blk|
      called = true
      mth.call(*args, &blk)
    end

    obj = my_class.new
    obj.original
    expect(called).to be(true)
    expect(obj.original_called).to be(true)
  end

  it "hooks singleton method" do
    called = false
    described_class.hook_method(my_class.singleton_class, :original) do |mth, args, &blk|
      called = true
      mth.call(*args, &blk)
    end

    my_class.original
    expect(called).to be(true)
    expect(my_class.original_called).to be(true)
  end

  it "injects debugger" do
    allow_any_instance_of(Binding).to receive(:pry)
    described_class.inject_debugger(my_class, :original)
    obj = my_class.new
    obj.original
  end
end
