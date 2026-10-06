return {
	UI = {
		currency = "$",
		main = {
			item = {
				addCart = "Sepete Ekle",
			},
		},
		cart = {
			payment = {
				title = "Ödeme",
				payBank = "Banka",
				payCash = "Nakit",
			},
		},
	},

	Interaction = {
		HelpText = "~INPUT_CONTEXT~  Ürün Kataloğunu Görüntüle", --? Buton Referansı: https://docs.fivem.net/docs/game-references/controls
		FloatingText = "~INPUT_CONTEXT~ Ürün Kataloğunu Görüntüle", --? Buton Referansı: https://docs.fivem.net/docs/game-references/controls
		Target = {
			Icon = "fa-solid fa-cart-shopping", --? İkon Referansı: https://fontawesome.com/icons
			Label = "Ürün Kataloğunu Görüntüle",
		},
	},

	Dialog = {
		License = {
			Header = "Bu dükkana erişmek için bir **%s** gerekli!",
			Content = "**%s** satın almak ister misiniz? Ücreti **$%s**.",
		},
	},

	Notify = {
		Requirement = {
			Job = { title = "Erişim Gereksinimi", description = "Bu dükkana erişmek için **%s** mesleğine sahip olmanız gerekiyor!", type = "warning" },
			JobGrade = { title = "Erişim Gereksinimi", description = "Meslek dereceniz bu dükkana erişmek için yeterli değil!", type = "warning" },
			License = { title = "Erişim Gereksinimi", description = "Bu dükkana erişmek için bir **%s** gerekli!", type = "warning" },
		},
		CantCarry = {
			Item = { title = "Taşıma Kısıtlaması", description = "**%s** öğesini taşıyamazsınız.", type = "error" },
			Weapons = { title = "Taşıma Kısıtlaması", description = "Birden fazla **%s** taşıyamazsınız.", type = "error" },
		},
		NoMoney = {
			Shop = { title = "Yetersiz Bakiye", description = "Satın alma işlemini gerçekleştirmek için yeterli paranız yok.", type = "error" },
			License = { title = "Yetersiz Bakiye", description = "**%s** satın almak için yeterli paranız yok.", type = "error" },
		},
		PaymentSuccess = {
			Shop = { title = "Satın Alma Başarılı", description = "Ürün(ler) **$%s** karşılığında başarıyla satın alındı.", type = "success" },
			License = { title = "Satın Alma Başarılı", description = "**%s**, **$%s** karşılığında başarıyla satın alındı.", type = "success" },
		},
	},
}
