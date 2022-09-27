require 'rails_helper'

RSpec.describe 'Authorization requests', type: :feature do
  context 'when client sends invalid params' do
    it 'displays error messages' do
      visit '/auth'

      expect(page).to have_content('The following errors were found in the provided parameters:')
    end
  end

  context 'when client sends valid params' do
    context 'without params[:me]' do
      it 'displays a form' do
        params = attributes_for(:authorization_request)

        visit "/auth?#{URI.encode_www_form(params)}"

        expect(page).to have_css('label[for="me"]', text: 'Your website’s URL')

        within('form') do
          fill_in 'me', with: "https://#{Faker::Internet.domain_name}"
        end

        click_button 'Submit'

        # expect(page).to ...
      end
    end

    context 'with params[:me]' do
      it 'displays authentication options' do
        params = attributes_for(:authorization_request, :with_me_param)

        visit "/auth?#{URI.encode_www_form(params)}"

        # expect(page).to ...
      end
    end
  end
end
