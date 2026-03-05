import Foundation

enum ChatWelcomeLocalization {
    private static func matchLanguage(_ lang: String) -> String? {
        let l = lang.lowercased()
        if l.contains("dutch") || l.contains("nederland") || l == "nl" { return "nl" }
        if l.contains("german") || l.contains("deutsch") || l == "de" { return "de" }
        if l.contains("french") || l.contains("français") || l.contains("francais") || l == "fr" { return "fr" }
        if l.contains("spanish") || l.contains("español") || l.contains("espanol") || l == "es" { return "es" }
        if l.contains("portuguese") || l.contains("português") || l.contains("portugues") || l == "pt" { return "pt" }
        if l.contains("italian") || l.contains("italiano") || l == "it" { return "it" }
        return nil
    }

    static func title(for lang: String) -> String {
        switch matchLanguage(lang) {
        case "nl": return "Vraag over je dag"
        case "de": return "Frag zu deinem Tag"
        case "fr": return "Posez des questions sur votre journée"
        case "es": return "Pregunta sobre tu día"
        case "pt": return "Pergunte sobre o seu dia"
        case "it": return "Chiedi della tua giornata"
        default:   return "Ask about your day"
        }
    }

    static func subtitle(for lang: String) -> String {
        switch matchLanguage(lang) {
        case "nl": return "Zet je tijdlijn om in directe antwoorden."
        case "de": return "Verwandle deine Zeitleiste in sofortige Antworten."
        case "fr": return "Transformez votre chronologie en réponses instantanées."
        case "es": return "Convierte tu línea de tiempo en respuestas instantáneas."
        case "pt": return "Transforme sua linha do tempo em respostas instantâneas."
        case "it": return "Trasforma la tua cronologia in risposte istantanee."
        default:   return "Turn your timeline into instant answers."
        }
    }

    static func sectionHeader(for lang: String) -> String {
        switch matchLanguage(lang) {
        case "nl": return "Probeer een van deze"
        case "de": return "Probiere einen davon"
        case "fr": return "Essayez l'un de ceux-ci"
        case "es": return "Prueba uno de estos"
        case "pt": return "Experimente um destes"
        case "it": return "Prova uno di questi"
        default:   return "Try one of these"
        }
    }

    static func placeholder(for lang: String) -> String {
        switch matchLanguage(lang) {
        case "nl": return "Vraag over je dag..."
        case "de": return "Frag zu deinem Tag..."
        case "fr": return "Posez des questions..."
        case "es": return "Pregunta sobre tu día..."
        case "pt": return "Pergunte sobre o seu dia..."
        case "it": return "Chiedi della tua giornata..."
        default:   return "Ask about your day..."
        }
    }

    static func prompts(for lang: String) -> (String, String, String, String) {
        switch matchLanguage(lang) {
        case "nl":
            return (
                "Genereer standup notities voor gisteren",
                "Wat heb ik afgelopen week gedaan?",
                "Wat leidde me het meest af afgelopen week?",
                "Haal mijn data op van de afgelopen week en vertel me iets interessants"
            )
        case "de":
            return (
                "Erstelle Standup-Notizen für gestern",
                "Was habe ich letzte Woche geschafft?",
                "Was hat mich letzte Woche am meisten abgelenkt?",
                "Hole meine Daten der letzten Woche und erzähl mir etwas Interessantes"
            )
        case "fr":
            return (
                "Génère des notes de standup pour hier",
                "Qu'est-ce que j'ai fait la semaine dernière ?",
                "Qu'est-ce qui m'a le plus distrait la semaine dernière ?",
                "Récupère mes données de la semaine dernière et dis-moi quelque chose d'intéressant"
            )
        case "es":
            return (
                "Genera notas de standup de ayer",
                "¿Qué hice la semana pasada?",
                "¿Qué me distrajo más la semana pasada?",
                "Toma mis datos de la última semana y cuéntame algo interesante"
            )
        case "pt":
            return (
                "Gere notas de standup de ontem",
                "O que fiz na semana passada?",
                "O que mais me distraiu na semana passada?",
                "Pega meus dados da última semana e me conta algo interessante"
            )
        case "it":
            return (
                "Genera note standup per ieri",
                "Cosa ho fatto la settimana scorsa?",
                "Cosa mi ha distratto di più la settimana scorsa?",
                "Prendi i miei dati dell'ultima settimana e dimmi qualcosa di interessante"
            )
        default:
            return (
                "Generate standup notes for yesterday",
                "What did I get done last week?",
                "What distracted me the most this past week?",
                "Pull my data from the last week and tell me something interesting"
            )
        }
    }
}
