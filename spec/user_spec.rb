RSpec.describe Mysqlman::User do
  describe '#name_with_host' do
    it 'return hash includes name and host' do
      expect(Mysqlman::User.new(user: 'root').name_with_host).to eq({ 'user' => 'root', 'host' => '%' })
    end
  end

  describe '#exists?' do
    context 'when the user exists' do
      it 'return true' do
        expect(Mysqlman::User.new(user: 'root').exists?).to eq true
      end
    end
    context 'when the user does not exist' do
      it 'return false' do
        expect(Mysqlman::User.new(user: 'wrong_user').exists?).to eq false
      end
    end
  end

  describe '#create' do
    let(:user) { Mysqlman::User.new(user: 'before_create') }
    context 'no debug mode' do
      it 'created user' do
        expect(user.create.exists?).to eq true
      end
    end
    context 'debug mode' do
      it 'did not create user' do
        expect(user.create(true).exists?).to eq false
      end
    end
  end

  describe '#drop' do
    let(:user) { Mysqlman::User.new(user: 'before_drop').create }
    context 'no debug mode' do
      it 'droped user' do
        user.drop
        expect(user.exists?).to eq false
      end
    end
    context 'debug mode' do
      it 'did not drop user' do
        user.drop(true)
        expect(user.exists?).to eq true
      end
    end
  end

  describe '.find' do
    it 'return user instance' do
    end
  end
  describe '.all' do
    it 'return all users instance' do
    end
  end
end
