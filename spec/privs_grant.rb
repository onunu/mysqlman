RSpec.describe Mysqlman::PrivsGrant do
  let(:tester) { Mysqlman::User.new(user: 'tester').create }
  let(:test_priv) { { schema: nil, table: nil, type: 'SELECT' } }

  describe '#grant' do
    context 'no debug mode' do
      it 'the priv granted' do
        tester.privs.grant(test_priv)
        expect(tester.privs.fetch.include?(test_priv)).to eq true
      end
    end
    context 'debug mode' do
      it 'the priv did not grant' do
        tester.privs.grant(test_priv, true)
        expect(tester.privs.fetch.include?(test_priv)).to eq false
      end
    end
  end

  describe '#revoke' do
    context 'no debug mode' do
      it 'the priv revoked' do
        tester.privs.grant(test_priv)
        tester.privs.revoke(test_priv)
        expect(tester.privs.fetch.include?(test_priv)).to eq false
      end
    end
    context 'debug mode' do
      it 'the priv did not revoke' do
        tester.privs.grant(test_priv)
        tester.privs.revoke(test_priv, true)
        expect(tester.privs.fetch.include?(test_priv)).to eq true
      end
    end
  end
end
