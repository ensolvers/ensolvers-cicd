const jsdom = require('jsdom').JSDOM;
const jquery = require('jquery');

export interface SEOOptimization {
    [mainSelector: string]: SEOOptimizationReplacements
}

export type SEOOptimizationReplacements = {[selector: string]: string};

class SEOOptimizer {

    optimize(html: string, optimizations: SEOOptimization): string{
        var dom = new jsdom(html, {});
        var $ = jquery(dom.window);
    
        for (const selector in optimizations) {
            const element = $(selector)
            const replacements = optimizations[selector]
    
            for (const replacementSelector in replacements) {
                $(element).find(replacementSelector).remove();
                element.append(replacements[replacementSelector])
            }
        }
    
        return $("html")[0].outerHTML;
    }

}

export default new SEOOptimizer();