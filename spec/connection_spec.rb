RSpec.describe Mysqlman::Connection do
  describe '#query' do
    it 'can execute any query' do
      expect(Mysqlman::Connection.new.query('SELECT VERSION()')).not_to be nil
    end
  end
end
