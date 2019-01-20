RSpec.describe DailySalesRevenue do
  describe '.run' do
    context 'nothing in the input => nothing in the output' do
      it { expect(DailySalesRevenue.run({})).to eq(totals:[]) }
    end

    context 'one simple one-page communication is 0.10€' do
      let(:day) { Date.parse('2018-12-06') }

      let(:input) do
        {
          'communications' => [
            {
              'id' => 123,
              'practitioner_id' => 456,
              'pages_number' => 1,
              'color' => false,
              'sent_at' => "#{day} 17:11:05"
            }
          ]
        }
      end

      let(:expected_output) do
        {
          totals: [
            {
              sent_on: day,
              total: 0.10
            }
          ]
        }
      end

      it { expect(DailySalesRevenue.run(input)).to eq expected_output }
    end

    context 'two simple one-page communications' do
      context 'on two different days makes 0.10€ for each' do
        let(:day1) { Date.parse('2018-12-06') }
        let(:day2) { Date.parse('2018-12-07') }

        let(:input) do
          {
            'communications' => [
              {
                'id' => 123,
                'practitioner_id' => 456,
                'pages_number' => 1,
                'color' => false,
                'sent_at' => "#{day2} 17:11:05"
              },
              {
                'id' => 124,
                'practitioner_id' => 456,
                'pages_number' => 1,
                'color' => false,
                'sent_at' => "#{day1} 17:11:05"
              }
            ]
          }
        end

        let(:expected_output) do
          {
            totals: [
              {
                sent_on: day1,
                total: 0.10
              },
              {
                sent_on: day2,
                total: 0.10
              }
            ]
          }
        end

        it { expect(DailySalesRevenue.run(input)).to eq expected_output }
      end

      context 'on the same day makes 0.20€ for both' do
        let(:day) { Date.parse('2018-12-06') }

        let(:input) do
          {
            'communications' => [
              {
                'id' => 123,
                'practitioner_id' => 456,
                'pages_number' => 1,
                'color' => false,
                'sent_at' => "#{day} 17:11:05"
              },
              {
                'id' => 124,
                'practitioner_id' => 456,
                'pages_number' => 1,
                'color' => false,
                'sent_at' => "#{day} 17:11:05"
              }
            ]
          }
        end

        let(:expected_output) do
          {
            totals: [
              {
                sent_on: day,
                total: 0.20
              }
            ]
          }
        end

        it { expect(DailySalesRevenue.run(input)).to eq expected_output }
      end
    end

    context 'multiple pages are 0.07€ a page after the first' do
      let(:day) { Date.parse('2018-12-06') }

      let(:input) do
        {
          'communications' => [
            {
              'id' => 123,
              'practitioner_id' => 456,
              'pages_number' => 5,
              'color' => false,
              'sent_at' => "#{day} 17:11:05"
            }
          ]
        }
      end

      let(:expected_output) do
        {
          totals: [
            {
              sent_on: day,
              total: 0.38
            }
          ]
        }
      end

      it { expect(DailySalesRevenue.run(input)).to eq expected_output }
    end

    context 'color mode' do
      context 'color mode is on' do
        let(:day) { Date.parse('2018-12-06') }

        let(:input) do
          {
            'communications' => [
              {
                'id' => 123,
                'practitioner_id' => 456,
                'pages_number' => 1,
                'color' => true,
                'sent_at' => "#{day} 17:11:05"
              }
            ]
          }
        end

        let(:expected_output) do
          {
            totals: [
              {
                sent_on: day,
                total: 0.28
              }
            ]
          }
        end

        it { expect(DailySalesRevenue.run(input)).to eq expected_output }
      end

      context 'color mode is off' do
        context 'explicitely' do
          let(:day) { Date.parse('2018-12-06') }

          let(:input) do
            {
              'communications' => [
                {
                  'id' => 123,
                  'practitioner_id' => 456,
                  'pages_number' => 1,
                  'color' => false,
                  'sent_at' => "#{day} 17:11:05"
                }
              ]
            }
          end

          let(:expected_output) do
            {
              totals: [
                {
                  sent_on: day,
                  total: 0.10
                }
              ]
            }
          end

          it { expect(DailySalesRevenue.run(input)).to eq expected_output }
        end

        context 'by default' do
          let(:day) { Date.parse('2018-12-06') }

          let(:input) do
            {
              'communications' => [
                {
                  'id' => 123,
                  'practitioner_id' => 456,
                  'pages_number' => 1,
                  'sent_at' => "#{day} 17:11:05"
                }
              ]
            }
          end

          let(:expected_output) do
            {
              totals: [
                {
                  sent_on: day,
                  total: 0.10
                }
              ]
            }
          end

          it { expect(DailySalesRevenue.run(input)).to eq expected_output }
        end
      end
    end

    context 'express deliveries' do
      context 'express deliveries is on' do
        let(:day) { Date.parse('2018-12-06') }

        let(:input) do
          {
            'practitioners' => [
              {
                'id' => 456,
                'first_name' => 'John',
                'last_name' => 'You-Knew-Something-They-Did-Not Snow',
                'express_delivery' => true
              }
            ],
            'communications' => [
              {
                'id' => 123,
                'practitioner_id' => 456,
                'pages_number' => 1,
                'color' => false,
                'sent_at' => "#{day} 17:11:05"
              }
            ]
          }
        end

        let(:expected_output) do
          {
            totals: [
              {
                sent_on: day,
                total: 0.70
              }
            ]
          }
        end

        it { expect(DailySalesRevenue.run(input)).to eq expected_output }
      end

      context 'express delivery is off' do
        context 'explicitely' do
          let(:day) { Date.parse('2018-12-06') }

          let(:input) do
            {
              'practitioners' => [
                {
                  'id' => 456,
                  'first_name' => 'John',
                  'last_name' => 'You-Knew-Something-They-Did-Not Snow',
                  'express_delivery' => false
                }
              ],
              'communications' => [
                {
                  'id' => 123,
                  'practitioner_id' => 456,
                  'pages_number' => 1,
                  'color' => false,
                  'sent_at' => "#{day} 17:11:05"
                }
              ]
            }
          end

          let(:expected_output) do
            {
              totals: [
                {
                  sent_on: day,
                  total: 0.10
                }
              ]
            }
          end

          it { expect(DailySalesRevenue.run(input)).to eq expected_output }
        end


        context 'by default' do
          let(:day) { Date.parse('2018-12-06') }

          let(:input) do
            {
              'practitioners' => [
                {
                  'id' => 456,
                  'first_name' => 'John',
                  'last_name' => 'You-Knew-Something-They-Did-Not Snow'
                }
              ],
              'communications' => [
                {
                  'id' => 123,
                  'practitioner_id' => 456,
                  'pages_number' => 1,
                  'color' => false,
                  'sent_at' => "#{day} 17:11:05"
                }
              ]
            }
          end

          let(:expected_output) do
            {
              totals: [
                {
                  sent_on: day,
                  total: 0.10
                }
              ]
            }
          end

          it { expect(DailySalesRevenue.run(input)).to eq expected_output }
        end
      end
    end

    context 'real-life-ish example' do
      let(:input) do
        JSON.parse(File.read('./data.json'))
      end

      let(:expected_output) do
        JSON.parse(File.read('./output.json')).to_json
      end

      subject(:output) do
        DailySalesRevenue.run(input).to_json
      end

      it { expect(output).to eq expected_output }
    end
  end
end

