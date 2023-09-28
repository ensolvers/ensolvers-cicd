/// <reference types="cypress" />

const eventUrl = Cypress.env('url');

describe('Test google search', () => {
  beforeEach(() => {
    cy.visit('https://google.com')
      .wait(1000);
  })

  it('search', () => {
      cy.log(eventUrl);
      cy.get('textarea:eq(0)')
        .type('site:' + eventUrl )
        .type('{enter}');

      cy.wait(1000);

      cy.get('div#search').find('a[href*="' + eventUrl + '"]').should('exist');
    });
})