RSpec.describe Mysqlman::Privs do
  describe '#fetch' do
    context 'nomal privs' do
      before do
        Mysqlman::User.new(user: 'tester').create
        Mysqlman::Connection.instance.query('GRANT SELECT ON *.* TO \'tester\'@\'%\'')
      end
      let(:tester) { Mysqlman::User.new(user: 'tester') }
      it 'return privs array' do
        expect(tester.privs.fetch).to eq [{ schema: nil, table: nil, type: 'SELECT' }]
      end
    end
    context 'include grant option' do
      before do
        Mysqlman::User.new(user: 'tester').create
        Mysqlman::Connection.instance.query('GRANT SELECT ON *.* TO \'tester\'@\'%\' WITH GRANT OPTION')
      end
      let(:tester) { Mysqlman::User.new(user: 'tester') }
      it 'return privs array with grant option' do
        expect(tester.privs.fetch).to eq [
          { schema: nil, table: nil, type: 'SELECT' },
          { schema: nil, table: nil, type: 'GRANT OPTION' }
        ]
      end
    end
  end
end
