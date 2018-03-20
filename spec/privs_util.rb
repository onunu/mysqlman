RSpec.describe Mysqlman::PrivsUtil do
  describe '.all' do
    let(:expected) do
      [
        { schema: 'test_schema', table: 'test_table', type: 'ALTER' },
        { schema: 'test_schema', table: 'test_table', type: 'CREATE VIEW' },
        { schema: 'test_schema', table: 'test_table', type: 'CREATE' },
        { schema: 'test_schema', table: 'test_table', type: 'DELETE' },
        { schema: 'test_schema', table: 'test_table', type: 'DROP' },
        { schema: 'test_schema', table: 'test_table', type: 'INDEX' },
        { schema: 'test_schema', table: 'test_table', type: 'INSERT' },
        { schema: 'test_schema', table: 'test_table', type: 'SELECT' },
        { schema: 'test_schema', table: 'test_table', type: 'SHOW VIEW' },
        { schema: 'test_schema', table: 'test_table', type: 'TRIGGER' },
        { schema: 'test_schema', table: 'test_table', type: 'UPDATE' }
      ]
    end
    context 'do not include grant option' do
      it 'all privileges of target lebel' do
        expect(Mysqlman::Privs.all('test_schema', 'test_table', false)).to eq expected
      end
    end
    context 'include grant option' do
      let(:grant_option) { { schema: 'test_schema', table: 'test_table', type: 'GRANT OPTION' } }
      it 'all privileges of target lebel with grant option' do
        expect(Mysqlman::Privs.all('test_schema', 'test_table', true)).to eq expected.push(grant_option)
      end
    end
  end
end
