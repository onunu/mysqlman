RSpec.describe Mysqlman::Role do
  describe '#privs' do
    let(:role) { Mysqlman::Role.new('tester', config) }
    context 'only global privs' do
      let(:config) do
        { 'global' => %w[select update] }
      end
      let(:expected_privs) do
        [
          { schema: nil, table: nil, type: 'SELECT' },
          { schema: nil, table: nil, type: 'UPDATE' }
        ]
      end
      it 'return correct privs' do
        expect(role.privs).to eq expected_privs
      end
    end
    context 'multiple levels privs' do
      let(:config) do
        {
          'global' => ['create user', 'select'],
          'schema' => { 'mysql' => ['update'] }
        }
      end
      let(:expected_privs) do
        [
          { schema: nil, table: nil, type: 'CREATE USER' },
          { schema: nil, table: nil, type: 'SELECT' },
          { schema: 'mysql', table: nil, type: 'UPDATE' }
        ]
      end
      it 'return correct privs' do
        expect(role.privs).to eq expected_privs
      end
    end
    context 'include all priv' do
      let(:config) do
        { 'table' =>
          { 'mysql' => { 'user' => ['all'] } } }
      end
      let(:expected_privs) do
        [
          { schema: 'mysql', table: 'user', type: 'ALTER' },
          { schema: 'mysql', table: 'user', type: 'CREATE VIEW' },
          { schema: 'mysql', table: 'user', type: 'CREATE' },
          { schema: 'mysql', table: 'user', type: 'DELETE' },
          { schema: 'mysql', table: 'user', type: 'DROP' },
          { schema: 'mysql', table: 'user', type: 'INDEX' },
          { schema: 'mysql', table: 'user', type: 'INSERT' },
          { schema: 'mysql', table: 'user', type: 'SELECT' },
          { schema: 'mysql', table: 'user', type: 'SHOW VIEW' },
          { schema: 'mysql', table: 'user', type: 'TRIGGER' },
          { schema: 'mysql', table: 'user', type: 'UPDATE' }
        ]
      end
      it 'return correct privs' do
        expect(role.privs).to eq expected_privs
      end
    end

    describe '.all' do
      before do
        allow(YAML).to receive(:load_file).and_return(configs)
      end
      context 'single role in one file' do
        let(:configs) do
          {
            'tester' => { 'global' => %w[select update] }
          }
        end
        it 'return all role instance' do
          expect(Mysqlman::Role.all.map(&:name)).to eq ['tester']
        end
      end
      context 'multiple roles in one file' do
        let(:configs) do
          {
            'tester' => { 'global' => %w[select update] },
            'tester_alt' => { 'global' => %w[select update] }
          }
        end
        it 'return all role instance' do
          expect(Mysqlman::Role.all.map(&:name)).to eq %w[tester tester_alt]
        end
      end
    end

    describe '.find' do
      before do
        allow(YAML).to receive(:load_file).and_return(configs)
      end
      let(:configs) do
        {
          'tester' => { 'global' => %w[select update] },
          'tester_alt' => { 'global' => %w[select update] }
        }
      end
      it 'return the role instance' do
        expect(Mysqlman::Role.find('tester').name).to eq 'tester'
      end
    end
  end
end
