require 'spec_helper'

describe SimpleService::Context do
  let(:context) {SimpleService::Context.new(test: 123)}

  it "has indifferent key access" do
    expect(context[:test]).to eq(123)
    expect(context['test']).to eq(123)
  end

  it "has method based key access" do
    expect(context.test).to eq(123)
  end

  it "returns the called actions" do
    fake_action = double()
    context.__add_called_action(fake_action, 1)
    expect(context.called_actions).to contain_exactly([fake_action, 1])
  end

  it "stores the current action" do
    context.current_action = 123
    expect(context.current_action).to eq(123)
  end

  it "defaults to no current action" do
    expect(context.current_action).to be_nil
  end

  it "can set the context to fail hard" do
    context.fail_hard!
    expect(context.fail_hard?).to be true
  end

  it "can set the context to fail soft" do
    context.fail_hard!
    context.fail_soft!
    expect(context.fail_hard?).to be false
  end

  it "returns if the context is failed" do
    context.fail!
    expect(context.failed?).to be true
    context.success!
    expect(context.failed?).to be false
  end

  it "returns the status message" do
    context.fail! 'oops'
    expect(context.message).to eq('oops')
  end

  it "returns if remaining actions should be skipped" do
    expect(context.skip_remaining?).to be false
  end

  it "can set the remaining actions to be skipped" do
    context.skip_remaining!
    expect(context.skip_remaining?).to be true
  end

  it "returns if the context is successful" do
    context.success!
    expect(context.success?).to be true
    context.fail!
    expect(context.success?).to be false
  end

  describe ".new" do
    it "has the proper defaults" do
      ctx = SimpleService::Context.new()
      expect(ctx.fail_hard?).to be false
      expect(ctx.message).to be_nil
      expect(ctx.success?).to be true
      expect(ctx.skip_remaining?).to be false
      expect(ctx.called_actions).to be_empty
    end

    it "correctly sets the passed hash values" do
      ctx = SimpleService::Context.new(test: 123, some: 'thing')
      expect(ctx[:test]).to eq(123)
      expect(ctx[:some]).to eq('thing')
    end

    it "can specify the default status" do
      ctx = SimpleService::Context.new({}, false)
      expect(ctx.success?).to be false
    end
  end

  describe ".build" do
    context "when passed a SimpleService::Context" do
      it "returns the context" do
        ctx = SimpleService::Context.new()
        expect(SimpleService::Context.build(ctx)).to eq(ctx)
      end
    end

    context "when passed a hash" do
      it "initializes a new context" do
        ctx = SimpleService::Context.new(test: 123)
        expect(ctx).to be_a(SimpleService::Context)
        expect(ctx.test).to eq(123)
      end
    end
  end

  describe "#fail!" do
    it "sets the status to failed" do
      context.fail!
      expect(context.failed?).to be true
    end

    it "sets the status message" do
      context.fail! 'oops'
      expect(context.message).to eq('oops')
    end

    it "translates the status message"

    it "sets the failure code"

    it "retains the key used to set the status message"

    context 'when set to fail hard' do
      before do
        context.fail_hard!
      end

      it "raises a SimpleService::Failure error" do
        expect {
          context.fail! 'oops'
        }.to raise_error {|error|
          expect(error).to be_a(SimpleService::Failure)
        }
      end

      it "the raised error has the failure message" do
        expect {
          context.fail! 'oops'
        }.to raise_error {|error|
          expect(error.message).to eq('oops')
        }
      end

      it "the raised error contains the context" do
        expect {
          context.fail! 'oops'
        }.to raise_error {|error|
          expect(error.context).to eq(context)
        }
      end
    end
  end

  describe "#stop_processing?" do
    context 'when failed' do
      it "returns true" do
        context.fail!
        expect(context.stop_processing?).to be true
      end
    end

    context 'when set to skip remaining actions' do
      it "returns true" do
        context.skip_remaining!
        expect(context.stop_processing?).to be true
      end
    end

    context 'when failed, and skipping remaining' do
      it "returns true" do
        context.skip_remaining!
        context.fail!
        expect(context.stop_processing?).to be true
      end
    end

    context 'when successful, and not skipping remaining' do
      it "returns false" do
        context.success!
        expect(context.stop_processing?).to be false
      end
    end
  end

  describe "#success!" do
    it "sets the status to successful" do
      context.fail!
      context.success!
      expect(context.success?).to be true
    end

    it "sets the status message" do
      context.success! 'done'
      expect(context.message).to eq('done')
    end

    it "translates the status message"

    it "clears an existing failure code"

    it "retains the key used to set the status message"
  end
end
