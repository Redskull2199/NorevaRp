import importTemplate from './utils/importTemplate.js';
import inlinesvg from './utils/inlineSvg.js';
import { FormatMoney, CalculateVehicleStatistic, ShowNotify } from './utils/functions.js';

const preview = {
    template: await importTemplate('./pages/preview.html')
}
const dashboard = {
    template: await importTemplate('./pages/bossmenu/dashboard.html')
}
const company = {
    template: await importTemplate('./pages/bossmenu/company.html')
}
const companysettings = {
    template: await importTemplate('./pages/bossmenu/company/settings.html')
}
const companystaffsettings = {
    template: await importTemplate('./pages/bossmenu/company/staffsettings.html')
}
const bosspopup = {
    template: await importTemplate('./pages/bossmenu/bosspopup.html')
}
const perms = {
    template: await importTemplate('./pages/bossmenu/perms.html')
}
const feedbackcomplains = {
    template: await importTemplate('./pages/bossmenu/feedbacks.html')
}
const vehicles = {
    template: await importTemplate('./pages/bossmenu/vehicles.html')
}
const category = {
    template: await importTemplate('./pages/bossmenu/category.html')
}
const buyvehicle = {
    template: await importTemplate('./pages/bossmenu/buyvehicle.html')
}

const store = Vuex.createStore({
    state: {},
    mutations: {},
    actions: {}
});

const app = Vue.createApp({
    components: {
        preview,
        inlinesvg,
        dashboard,
        company,
        companysettings,
        companystaffsettings,
        perms,
        feedbackcomplains,
        vehicles,
        category,
        buyvehicle,
        bosspopup
    },
    
    data: () => ({
        Show: false,
        ShowTestDriveTime: false,
        MainPage: 'Normal', // 'Normal', 'Component', "Bossmenu"
        activePage: 'dashboard', // 'preview', 'dashboard', 'company', 'companysettings', 'companystaffsettings', 'perms', 'feedbackcomplains', 'vehicles', 'category', 'buyvehicle'
        HasOwner: false,

        // Player Information
        PlayerName: "Oph3Z Second",
        PlayerRank: 'Owner',
        PlayerMoney: 1000000,
        PlayerPfp: "URL",

        // Main Informations
        CurrentVehicleshop: -1,
        ShiftPressed: false,
        DraggingCheck: false,
        MouseX: null,
        MouseY: null,
        CameraAngle: 'exterior',
        TestDriveTime: 0,

        // Vehicleshop Variables
        VehicleShopName: "Oph3Z's Dealership",
        VehicleshopDescription: "",
        VehicleShopStar: 4,
        Discount: 0,
        TestDrivePrice: 7500,
        ShowColorPicker: false,
        ColorPickerColor: "#FFFFFF",
        SelectedColor: null,
        ColorsTable: [],
        AllowPlateChange: true,
        PlateChangePrice: 0,
        ShowPlateChange: false,
        PlateInput: "",
        ChangedPlate: false,
        CategoryList: [],
        NewCategoryList: [],
        SelectedVehicleEditCategory: -1,
        SelectedVehicleCategory: 'all',
        VehiclesTable: [],
        AllVehicleData: [],
        SelectedBuyVehicle: -1, // Seçilen araç (Araç satın alma ekranında | Boss menu)
        SelectedVehicleTable: {
            VehicleIndex: -1,
            VehicleHash: "",
            VehicleLabel: "",
            VehicleModel: "",
            VehiclePrice: 0,
            VehicleStock: null,
            VehicleDiscount: 0,
            VehicleTopSpeed: 0,
            VehicleBraking: 0,
            VehicleAcceleration: 0,
            VehicleSuspension: 0,
            VehicleHandling: 0,
        },
        SearchInput: "",
        IsSearching: false,
        ShowFeedback: false,
        Feedbacks: [],
        VehicleStatisticMaxValues: {
            MaxSpeed: 500,
            MaxBrake: 200,
            MaxAcceleration: 2500,
            MaxSuspension: 400,
            MaxHandling: 100
        },

        // Boss menu Variables
        CompanyMoney: 0,
        BossmenuCategory: [],
        SelectedBossmenuCategory: 0,
        Preorders: [
            {
                identifier: "",
                requestor: "Oph3Z Test",
                vehiclehash: "t20",
                vehiclemodel: "T20",
                price: 10000000
            },
        ],
        EmployeesTable: [],
        SoldVehiclesLog: [],
        Transactions: [],
        PermsTable: [],
        SelectedPerm: -1,
        OriginalPermsTable: null,
        BossmenuPageSettings: {
            PreorderPage: 1,
            SoldVehiclesPage: 1,
            TransactionsPage: 1,
            EmployeeWithPenaltyPage: 1,
            EmployeesPage: 1,
        },
        FeedbackComplaintScreen: -1,
        VehicleEditScreen: -1, // Selected vehicle table number
        SelectedShowCategory: 0, // 'category' - page (When clicking 'Show')

        // Notify
        NotifySettings: {
            Show: false,
            Type: '', // success, information, error
            Message: '',
            Time: 0,
        },

        // Popup Settings
        ShowPopupScrren: false,
        NormalPopupSettings: {
            Show: false,
            HeaderOne: '',
            HeaderTwo: '',
            Description: '',
            Function: null
        },
        FeedbackPopupSettings: {
            Show: false,
            Rating: null,
            Message: '',
        },
        ComplaintPopupSettings: {
            Show: false,
            Message: '',
        },

        // Boss Menu Popup Settings
        ShowBossPopup: '', // deposit, withdraw, createperm, vehicleedit, createcategory, editcategory, buyvehicle

        // Popup Without UI (Req to other players)
        ShowPopupToTarget: '', // 'TransferRequest', 'JobReq'

        // TransferReq Settings
        TransferReqCompanyName: 'Oph3Z Vehicleshop',
        TransferReqCompanyPrice: 1000000,
        TransferReqFunctions: '',
        TransferReqSender: null,
        TransferReqTarget: null,

        // JobReq Settings
        JobReqCompanyName: 'Test Vehicleshop',
        JobReqSalary: 15000,
        JobReqSender: null,
        JobReqTarget: null,

        // Detailed Variables
        CheckProfanities: true,
        Profanities: [],
        FeedbackCharacters: {},
        ComplaintCharacters: {},

        // Tables
        ComplainTable: [],

        Inputs: {
            SoldVehiclesInput: '', // Satılmış araçlar arama input
            CompanyNameInput: '', // Şirket ismi değiştirme
            TransferIdInput: '',  // Transfer
            TransferPriceInput: '', // Transfer
            DiscountInput: '', // İndirim
            BonusesInput: '', // Prim
            RaiseInput: '', // Zam
            TransactionsInput: '', // Para Çekme/Yatırma arama input
            EmployeeIdInput: '', // İşe alma
            EmployeeSalaryInput: '', // İşe alma
            SalaryPenaltyIdInput: '', // Maaş cezası
            SalaryPenaltyInput: '', // İkinci input
            PenaltySearchInput: '', // Maaş cezası
            EmployeesInput: '', // Çalışanlar listesi
            DepositInput: '', // Para yatırma input
            WithdrawInput: '', // Para çekme input
            PermNameInput: '', // Perm oluşturma name
            PermLabelInput: '', // Perm oluşturma label
            CategoryNameInput: '', // Kategori oluşturma name
            CategoryLabelInput: '', // Kategori oluşturma label
        },

        EditVehicleInputs: {
            Name: '',
            Model: '',
            Img: '',
            Discount: '',
            Price: '',
        },

        BuyVehicleInputs: {
            Stock: 1,
            Price: '',
            SelectedCategoryIndex: -1
        },

        // Language
        Language: {},

        // Extras
        CurrentVehicleColor: null,
    }),

    methods: {
        setActivePage(page) {
            this.activePage = page
        },

        FormatMoney(s) {
            return FormatMoney(s)
        },

        BuyVehicle() {
            this.ShowPopupScrren = true
            this.NormalPopupSettings.Show = true
            this.NormalPopupSettings.HeaderOne = this.Language['buyvehicle_header']
            let SelectedVehiclePrice = this.SelectedVehicleTable.VehiclePrice
            if (this.Discount > 0) {
                SelectedVehiclePrice = SelectedVehiclePrice - (SelectedVehiclePrice * this.Discount / 100)
            } else if (this.SelectedVehicleTable.VehicleDiscount > 0) {
                SelectedVehiclePrice = SelectedVehiclePrice - (SelectedVehiclePrice * this.SelectedVehicleTable.VehicleDiscount / 100)
            }
            if (this.ChangedPlate) {
                this.NormalPopupSettings.HeaderTwo = '$' + this.FormatMoney(SelectedVehiclePrice) + ' + ' + this.FormatMoney(this.PlateChangePrice)
            } else {
                this.NormalPopupSettings.HeaderTwo = '$' + this.FormatMoney(SelectedVehiclePrice)
            }
            this.NormalPopupSettings.Description = this.Language['buyvehicle_description']
            this.NormalPopupSettings.Function = 'buyvehicle'
        },

        PreOrderVehicle() {
            this.ShowPopupScrren = true
            this.NormalPopupSettings.Show = true
            this.NormalPopupSettings.HeaderOne = this.Language['preordervehicle_header']
            let SelectedVehiclePrice = this.SelectedVehicleTable.VehiclePrice
            if (this.Discount > 0) {
                SelectedVehiclePrice = SelectedVehiclePrice - (SelectedVehiclePrice * this.Discount / 100)
            } else if (this.SelectedVehicleTable.VehicleDiscount > 0) {
                SelectedVehiclePrice = SelectedVehiclePrice - (SelectedVehiclePrice * this.SelectedVehicleTable.VehicleDiscount / 100)
            }
            this.NormalPopupSettings.HeaderTwo = '$' + this.FormatMoney(SelectedVehiclePrice)
            this.NormalPopupSettings.Description = this.Language['preordervehicle_description']
            this.NormalPopupSettings.Function = 'preordervehicle'
        },

        ConfirmBuyVehicle() {
            let SelectedVehiclePrice = this.SelectedVehicleTable.VehiclePrice
            if (this.Discount > 0) {
                SelectedVehiclePrice = SelectedVehiclePrice - (SelectedVehiclePrice * this.Discount / 100)
            } else if (this.SelectedVehicleTable.VehicleDiscount > 0) {
                SelectedVehiclePrice = SelectedVehiclePrice - (SelectedVehiclePrice * this.SelectedVehicleTable.VehicleDiscount / 100)
            }
            if (this.ChangedPlate) {
                SelectedVehiclePrice = SelectedVehiclePrice + this.PlateChangePrice
            }
            if (this.PlayerMoney >= SelectedVehiclePrice) {
                postNUI('BuyPlayerVehicle', {
                    vehicleshop: this.CurrentVehicleshop,
                    model: this.SelectedVehicleTable.VehicleHash,
                    price: SelectedVehiclePrice,
                    stock: this.SelectedVehicleTable.VehicleStock,
                    plate: this.PlateInput,
                    color: this.CurrentVehicleColor
                })
                this.ClosePopup('normal')
            } else {
                this.ShowNotify('error', this.Language['not_enough_money'], 2000)
            }
        },

        ConfirmPreorderVehicle() {
            let SelectedVehiclePrice = this.SelectedVehicleTable.VehiclePrice
            if (this.Discount > 0) {
                SelectedVehiclePrice = SelectedVehiclePrice - (SelectedVehiclePrice * this.Discount / 100)
            } else if (this.SelectedVehicleTable.VehicleDiscount > 0) {
                SelectedVehiclePrice = SelectedVehiclePrice - (SelectedVehiclePrice * this.SelectedVehicleTable.VehicleDiscount / 100)
            }
            if (this.PlayerMoney >= SelectedVehiclePrice) {
                postNUI('PreOrderVehicle', {
                    id: this.CurrentVehicleshop,
                    model: this.SelectedVehicleTable.VehicleHash,
                    price: SelectedVehiclePrice,
                    plate: this.PlateInput,
                    color: this.CurrentVehicleColor
                })
                this.ClosePopup('normal')
            } else {
                this.ShowNotify('error', this.Language['not_enough_money'], 2000)
            }
        },

        TestDrive() {
            this.ShowPopupScrren = true
            this.NormalPopupSettings.Show = true
            this.NormalPopupSettings.HeaderOne = this.Language['testdrive_header']
            this.NormalPopupSettings.HeaderTwo = '$' + this.FormatMoney(this.TestDrivePrice)
            this.NormalPopupSettings.Description = this.Language['testdrive_description']
            this.NormalPopupSettings.Function = 'testdrive'
        },

        StartTestDrive() {
            if (this.PlayerMoney >= this.TestDrivePrice) {
                postNUI('StartTestDrive', {
                    vehicleshop: this.CurrentVehicleshop,
                    vehicle: this.SelectedVehicleTable.VehicleHash,
                    color: this.CurrentVehicleColor
                })
                this.CloseUI(false)
            } else {
                this.ShowNotify('error', this.Language['not_enough_money'], 2000)
            }
        },

        VehicleshopPopupFunction(type) {
            if (type == 'testdrive') {
                this.StartTestDrive()
            } else if (type == 'buyvehicle') {
                this.ConfirmBuyVehicle()
            } else if (type == 'preordervehicle') {
                this.ConfirmPreorderVehicle()
            }
        },

        SetColorPicker() {
            this.ShowColorPicker = !this.ShowColorPicker

            if (this.ShowPlateChange) {
                this.ShowPlateChange = false
                this.PlateInput = ""
            }

            if (this.ShowColorPicker) {
                this.OpenColorPicker()
                postNUI('ChangeVehicleColorFromPopup', this.ColorPickerColor)
            } else {
                this.ColorPickerColor = "#FFFFFF"
                postNUI('ChangeVehicleColor', this.CurrentVehicleColor)
            }
        },

        OpenColorPicker() {
            this.$nextTick(() => {
                const colorPicker = new iro.ColorPicker("#color-picker", {
                    width: 160,
                    color: this.ColorPickerColor,
                    layout: [
                        {
                            component: iro.ui.Wheel,
                            options: {}
                        }
                    ]
                });
                colorPicker.on('color:change', (color) => {
                    this.ColorPickerColor = color.hexString;
                    postNUI('ChangeVehicleColorFromPopup', this.ColorPickerColor)
                });
            });
        },

        ChangeVehicleColorFromSelector() {
            this.ShowColorPicker = false
            postNUI('ChangeVehicleColorPermanent', this.ColorPickerColor)
            if (this.SelectedColor) {
                this.SelectedColor = null
            }
        },

        ChangePlateStatus() {
            if (this.ShowColorPicker) {
                this.ShowColorPicker = false
                this.ColorPickerColor = "#FFFFFF"
            }

            if (this.ShowPlateChange) {
                if (this.PlateInput.length <= 6 && this.PlateInput.length > 0) {
                    postNUI('CheckNewPlateStatus', this.PlateInput)
                } else {
                    if (this.PlateInput.length == 0) {
                        if (this.ChangedPlate) {
                            this.ShowPlateChange = false
                            postNUI('GenerateNewPlate')
                            this.ChangedPlate = false
                            this.ShowNotify('information', this.Language['new_generated_plate'], 4000)
                            setTimeout(() => {
                                postNUI('ResetCameraToNormal')
                            }, 1500)
                        } else {
                            this.ShowNotify('error', this.Language['dont_leave_empty'], 4000)
                        }
                    } else {
                        this.ShowNotify('error', this.Language['too_long_plate'], 3000)
                    }
                }
            } else {
                this.ShowPlateChange = true
                postNUI('ShowPlateCamera')
            }
        },

        SelectVehicle(index, v) {
            if (this.SelectedVehicleTable.VehicleIndex != index) {
                this.SelectedVehicleTable.VehicleIndex = index
                this.SelectedVehicleTable.VehicleHash = v.name
                this.SelectedVehicleTable.VehicleLabel = v.label
                this.SelectedVehicleTable.VehicleModel = v.model
                this.SelectedVehicleTable.VehiclePrice = v.price
                this.SelectedVehicleTable.VehicleStock = v.stock
                this.SelectedVehicleTable.VehicleDiscount = v.discount
                this.SelectedVehicleTable.VehicleTopSpeed = v.information.TopSpeed
                this.SelectedVehicleTable.VehicleBraking = v.information.Braking
                this.SelectedVehicleTable.VehicleAcceleration = v.information.Acceleration
                this.SelectedVehicleTable.VehicleSuspension = v.information.Suspension
                this.SelectedVehicleTable.VehicleHandling = v.information.Handling
                postNUI('CreateSelectedVehicle', this.SelectedVehicleTable.VehicleHash)
            }
            this.ChangedPlate = false
        },

        SelectVehicleColor(k) {
            if (this.SelectedColor != k) {
                this.SelectedColor = k
                postNUI('ChangeVehicleColor', k)
            }
        },

        ShowMoreCar(type) {
            const div = this.$refs.vc
            if (type == 'left') {
                div.scrollBy({ left: -window.innerWidth * 0.4, behavior: 'smooth' })
            } else if (type == 'right') {
                div.scrollBy({ left: window.innerWidth * 0.4, behavior: 'smooth' })
            }
        },

        Searching() {
            if (this.SearchInput != '') {
                this.IsSearching = true
            } else {
                this.IsSearching = false
            }
        },

        OpenFeedbacks() {
            this.ShowFeedback = !this.ShowFeedback

            if (this.ShowFeedback) {
                this.$nextTick(() => {
                    const divs = this.$refs.FeedbackScrollContainer
                    if (divs) {
                        divs.forEach(div => {
                            div.addEventListener('wheel', this.HandleFeedbackScroll)
                        });
                    }
                });
            } else {
                const divs = this.$refs.FeedbackScrollContainer
                if (divs) {
                    divs.forEach(div => {
                        div.removeEventListener('wheel', this.HandleFeedbackScroll)
                    });
                }
            }
        },

        HandleFeedbackScroll(event) {
            event.preventDefault();
            event.currentTarget.scrollBy({
                top: event.deltaY * 0.2,
                behavior: 'smooth'
            });
        },

        CalculateVehicleStatistic(type) {
            return CalculateVehicleStatistic(type, this.SelectedVehicleTable, this.VehicleStatisticMaxValues)
        },

        InspectExterior() {
            if (this.CameraAngle == 'interior') {
                postNUI('MoveCamToExterior')
                this.CameraAngle = 'exterior'
            }
        },

        InspectInterior() {
            if (this.CameraAngle == 'exterior') {
                postNUI('MoveCamToInterior')
                this.CameraAngle = 'interior'
            }
        },

        LeavePreviewMode() {
            this.MainPage = 'Normal'
            this.CameraAngle = 'interior'
            this.setActivePage(false)
            this.ShiftPressed = false
            this.DraggingCheck = false
            this.MouseX = null
            this.MouseY = null
            postNUI('ResetCameraAngle')
            this.InspectExterior()
        },

        ShowNotify(type, text, ms) {
            ShowNotify(type, text, ms, this.NotifySettings, SoundPlayer)
        },

        ShowPopup(type, headerone, headertwo, description, fnc) {
            this.ShowPopupScrren = true
            if (type == 'normal') {
                this.NormalPopupSettings.Show = true
                this.NormalPopupSettings.HeaderOne = headerone
                this.NormalPopupSettings.HeaderTwo = headertwo
                this.NormalPopupSettings.Description = description
                this.NormalPopupSettings.Function = fnc
            }
        },

        ClosePopup(type) {
            this.ShowPopupScrren = false
            if (type == 'normal') {
                this.NormalPopupSettings.Show = false
                this.NormalPopupSettings.HeaderOne = ''
                this.NormalPopupSettings.HeaderTwo = ''
                this.NormalPopupSettings.Description = ''
                this.NormalPopupSettings.Function = null
            }
        },

        CloseComplaintAndFeedback() {
            this.FeedbackPopupSettings.Show = false
            this.FeedbackPopupSettings.Rating = null
            this.FeedbackPopupSettings.Message = ''
            this.ComplaintPopupSettings.Show = false
            this.ComplaintPopupSettings.Message = ''
            postNUI('SetNuiFocus', false)
        },

        SendFeedback() {
            if (this.FeedbackPopupSettings.Rating) {
                if (this.FeedbackPopupSettings.Message.length >= this.FeedbackCharacters.MinimumCharacter) {
                    if (this.FeedbackPopupSettings.Message.length <= this.FeedbackCharacters.MaximumCharacter) {
                        if (this.CheckProfanities) {
                            const SearchProfanities = this.Profanities.filter(v => this.FeedbackPopupSettings.Message.includes(v))
                            if (SearchProfanities.length == 0) {
                                postNUI('SendFeedback', {
                                    id: this.CurrentVehicleshop,
                                    rating: this.FeedbackPopupSettings.Rating,
                                    message: this.FeedbackPopupSettings.Message
                                })
                                this.CloseComplaintAndFeedback()
                            } else {
                                postNUI('SendNormalNotify', {
                                    text: this.Language['feedback_stop_using_bad_words'],
                                    type: 'error'
                                })
                            }
                        } else {
                            postNUI('SendFeedback', {
                                id: this.CurrentVehicleshop,
                                rating: this.FeedbackPopupSettings.Rating,
                                message: this.FeedbackPopupSettings.Message
                            })
                            this.CloseComplaintAndFeedback()
                        }
                    } else {
                        postNUI('SendNormalNotify', {
                            text: this.Language['feedback_maximum_character'],
                            type: 'error'
                        })
                    }
                } else {
                    postNUI('SendNormalNotify', {
                        text: this.Language['feedback_minimum_character'],
                        type: 'error'
                    })
                }
            } else {
                postNUI('SendNormalNotify', {
                    text: this.Language['choose_point'],
                    type: 'error'
                })
            }
        },

        SendComplaint() {
            if (this.ComplaintPopupSettings.Message.length >= this.ComplaintCharacters.MinimumCharacter) {
                if (this.ComplaintPopupSettings.Message.length <= this.ComplaintCharacters.MaximumCharacter) {
                    if (this.CheckProfanities) {
                        const SearchProfanities = this.Profanities.filter(v => this.ComplaintPopupSettings.Message.includes(v))
                        if (SearchProfanities.length == 0) {
                            postNUI('SendComplaint', {
                                id: this.CurrentVehicleshop,
                                message: this.ComplaintPopupSettings.Message
                            })
                            this.CloseComplaintAndFeedback()
                        } else {
                            postNUI('SendNormalNotify', {
                                text: this.Language['complaint_stop_using_bad_words'],
                                type: 'error'
                            })
                        }
                    } else {
                        postNUI('SendComplaint', {
                            id: this.CurrentVehicleshop,
                            message: this.ComplaintPopupSettings.Message
                        })
                        this.CloseComplaintAndFeedback()
                    }
                } else {
                    postNUI('SendNormalNotify', {
                        text: this.Language['complaint_maximum_character'],
                        type: 'error'
                    })
                }
            } else {
                postNUI('SendNormalNotify', {
                    text: this.Language['complaint_minimum_character'],
                    type: 'error'
                })
            }
        },

        TotalBossmenuPages(type) {
            if (type == 'preorder') {
                return Math.ceil(this.Preorders.length / 7)
            } else if (type == 'soldvehicles') {
                return Math.ceil(this.FilterSoldVehiclesPage.length / 7)  
            } else if (type == 'transaction') {
                return Math.ceil(this.FilterTransactionsPage.length / 8) 
            } else if (type == 'employeewithpenalty') {
                return Math.ceil(this.FilterEmployeesWithPenaltyTable.length / 1)
            } else if (type == 'employee') {
                return Math.ceil(this.FilterEmployeesTable.length / 8)
            }
        },

        NextPage(type) {
            if (type == 'preorder') {
                if (this.BossmenuPageSettings.PreorderPage < this.TotalBossmenuPages('preorder')) {
                    this.BossmenuPageSettings.PreorderPage++
                }
            } else if (type == 'soldvehicles') {
                if (this.BossmenuPageSettings.SoldVehiclesPage < this.TotalBossmenuPages('soldvehicles')) {
                    this.BossmenuPageSettings.SoldVehiclesPage++
                }
            } else if (type == 'transaction') {
                if (this.BossmenuPageSettings.TransactionsPage < this.TotalBossmenuPages('transaction')) {
                    this.BossmenuPageSettings.TransactionsPage++
                }
            } else if (type == 'employeewithpenalty') {
                if (this.BossmenuPageSettings.EmployeeWithPenaltyPage < this.TotalBossmenuPages('employeewithpenalty')) {
                    this.BossmenuPageSettings.EmployeeWithPenaltyPage++
                }
            } else if (type == 'employee') {
                if (this.BossmenuPageSettings.EmployeesPage < this.TotalBossmenuPages('employee')) {
                    this.BossmenuPageSettings.EmployeesPage++
                }
            }
        },

        PrevPage(type) {
            if (type == 'preorder') {
                if (this.BossmenuPageSettings.PreorderPage > 1) {
                    this.BossmenuPageSettings.PreorderPage--
                }
            } else if (type == 'soldvehicles') {
                if (this.BossmenuPageSettings.SoldVehiclesPage > 1) {
                    this.BossmenuPageSettings.SoldVehiclesPage--
                }
            } else if (type == 'transaction') {
                if (this.BossmenuPageSettings.TransactionsPage > 1) {
                    this.BossmenuPageSettings.TransactionsPage--
                }
            } else if (type == 'employeewithpenalty') {
                if (this.BossmenuPageSettings.EmployeeWithPenaltyPage > 1) {
                    this.BossmenuPageSettings.EmployeeWithPenaltyPage--
                }
            } else if (type == 'employee') {
                if (this.BossmenuPageSettings.EmployeesPage > 1) {
                    this.BossmenuPageSettings.EmployeesPage--
                }
            }
        },

        // Perms
        CreatePerm() {
            if (this.Inputs.PermNameInput.length > 0 && this.Inputs.PermLabelInput.length > 0) {
                postNUI('CreatePermission', {
                    id: this.CurrentVehicleshop,
                    name: this.Inputs.PermNameInput,
                    label: this.Inputs.PermLabelInput
                })
            } else {
                this.ShowNotify('error', this.Language['dont_leave_empty'], 3000)
            }
        },

        RemovePerm(k) {
            if (this.PermCheck(this.PlayerRank, 'administration')) {
                postNUI('RemovePerm', {
                    id: this.CurrentVehicleshop,
                    name: this.PermsTable[k].name,
                })
            }
        },

        TogglePerms(k) {
            if (this.SelectedPerm < 0) return;

            if (!this.OriginalPermsTable) {
                this.OriginalPermsTable = JSON.parse(JSON.stringify(this.PermsTable[this.SelectedPerm].permissions));
            }
            let table = this.PermsTable[this.SelectedPerm].permissions;
            let permission = table[k];
            permission.value = !permission.value;
            this.$forceUpdate();
        },

        ResetPermsToggle() {
            if (this.OriginalPermsTable) {
                this.PermsTable[this.SelectedPerm].permissions = JSON.parse(JSON.stringify(this.OriginalPermsTable));
                this.OriginalPermsTable = null;
                this.$forceUpdate();
            }
        },

        SaveNewPermissions() {
            if (this.PermCheck(this.PlayerRank, 'administration')) {
                if (this.OriginalPermsTable) {
                    postNUI('SaveNewPermissions', {
                        id: this.CurrentVehicleshop,
                        name: this.PermsTable[this.SelectedPerm].name,
                        table: this.PermsTable[this.SelectedPerm].permissions,
                    })
                    this.PermsTable[this.SelectedPerm].permissions = JSON.parse(JSON.stringify(this.OriginalPermsTable));
                    this.SelectedPerm = -1
                    this.OriginalPermsTable = null;
                } else {
                    this.ShowNotify('error', this.Language['no_change'], 3000)
                }
            }
        },

        // Pre-order
        DeclinePreorder(requestor, vehicle, price) {
            if (this.PermCheck(this.PlayerRank, 'preorder')) {
                postNUI('DeclinePreorder', {
                    id: this.CurrentVehicleshop,
                    requestor: requestor,
                    vehicle: vehicle,
                    price: price
                })
            }
        },

        AcceptPreorder(requestor, vehicle, price) {
            if (this.PermCheck(this.PlayerRank, 'preorder')) {
                postNUI('AcceptPreorder', {
                    id: this.CurrentVehicleshop,
                    requestor: requestor,
                    vehicle: vehicle,
                    price: price
                })
            }
        },

        // Feedback & Complaint
        RemoveFeedbackComplaint(k, name, message, type) {
            if (type == 'complaint') {
                if (this.PermCheck(this.PlayerRank, 'removecomplaints')) {
                    postNUI('RemoveComplaint', {
                        id: this.CurrentVehicleshop,
                        name: name,
                        message: message
                    })
                    this.FeedbackComplaintScreen = -1
                }
            } else {
                if (this.PermCheck(this.PlayerRank, 'removefeedback')) {
                    postNUI('RemoveFeedback', {
                        id: this.CurrentVehicleshop,
                        name: name,
                        message: message
                    })
                    this.FeedbackComplaintScreen = -1
                }
            }
        },

        // Edit Vehicle
        OpenEditVehicleScreen(k, label, model, img, discount, price, category) {
            if (this.PermCheck(this.PlayerRank, 'editvehicle')) {
                const CategoryIndex = this.NewCategoryList.findIndex(v => v.name == category)
                this.SelectedVehicleEditCategory = CategoryIndex
                this.ShowBossPopup = 'vehicleedit'
                this.VehicleEditScreen = k
                this.EditVehicleInputs.Name = label
                this.EditVehicleInputs.Model = model
                this.EditVehicleInputs.Img = img
                this.EditVehicleInputs.Discount = discount
                this.EditVehicleInputs.Price = price
            }
        },

        CloseEditVehicleScreen() {
            this.SelectedVehicleEditCategory = -1
            this.ShowBossPopup = ''
            this.VehicleEditScreen = -1
            this.EditVehicleInputs.Name = ''
            this.EditVehicleInputs.Model = ''
            this.EditVehicleInputs.Img = ''
            this.EditVehicleInputs.Discount = ''
            this.EditVehicleInputs.Price = ''
        },

        SaveEditVehicleSection() {
            if (this.BossMenuFilterVehicles[this.VehicleEditScreen].label == this.EditVehicleInputs.Name && this.BossMenuFilterVehicles[this.VehicleEditScreen].model == this.EditVehicleInputs.Model && this.BossMenuFilterVehicles[this.VehicleEditScreen].img == this.EditVehicleInputs.Img && this.BossMenuFilterVehicles[this.VehicleEditScreen].discount == this.EditVehicleInputs.Discount && this.BossMenuFilterVehicles[this.VehicleEditScreen].price == this.EditVehicleInputs.Price && this.BossMenuFilterVehicles[this.VehicleEditScreen].category == this.NewCategoryList[this.SelectedVehicleEditCategory].name) {
                this.ShowNotify('error', this.Language['vehicle_edit_no_change'], 3000)
            } else {
                if (this.EditVehicleInputs.Name.length > 0 && this.EditVehicleInputs.Img.length > 0 && this.EditVehicleInputs.Price > 0) {
                    if (this.EditVehicleInputs.Discount > 0 && this.Discount > 0) {
                        this.ShowNotify('error', this.Language['already_has_a_discount'], 3000)
                    } else {
                        postNUI('EditVehicle', {
                            id: this.CurrentVehicleshop,
                            hash: this.BossMenuFilterVehicles[this.VehicleEditScreen].name,
                            name: this.EditVehicleInputs.Name,
                            model: this.EditVehicleInputs.Model,
                            img: this.EditVehicleInputs.Img,
                            category: this.NewCategoryList[this.SelectedVehicleEditCategory].name,
                            discount: this.EditVehicleInputs.Discount,
                            price: this.EditVehicleInputs.Price
                        })
                    }
                } else {
                    this.ShowNotify('error', this.Language['dont_leave_empty'], 3000)
                }
            }
        },

        // Category Page
        CategoryPageFilterVehicle(type) {
            if (type == 'all') {
                return this.VehiclesTable.filter(v => v.stock > 0)
            } else {
                return this.VehiclesTable.filter(v => v.category == type && v.stock > 0)
            }
        },

        CreateCategory() {
            if (this.PermCheck(this.PlayerRank, 'category')) {
                if (this.Inputs.CategoryNameInput.length > 0 && this.Inputs.CategoryLabelInput.length > 0) {
                    postNUI('CreateCategory', {
                        id: this.CurrentVehicleshop,
                        name: this.Inputs.CategoryNameInput,
                        label: this.Inputs.CategoryLabelInput
                    })
                    this.Inputs.CategoryNameInput = ''
                    this.Inputs.CategoryLabelInput = ''
                } else {
                    this.ShowNotify('error', this.Language['dont_leave_empty'], 3000)
                }
            }
        },

        RemoveCategory(name) {
            if (this.PermCheck(this.PlayerRank, 'category')) {
                postNUI('RemoveCategory', {
                    id: this.CurrentVehicleshop,
                    name: name
                })
            }
        },

        EditCategory(label) {
            if (this.PermCheck(this.PlayerRank, 'category')) {
                if (label.length > 0) {
                    postNUI('EditCategory', {
                        id: this.CurrentVehicleshop,
                        name: this.SelectedEditCategoryName,
                        label: label,
                    })
                } else {
                    this.ShowNotify('error', this.Language['dont_leave_empty'], 3000)
                }
            }
        },

        // Buy Vehicle Page
        OpenBuyVehicleScreen(k) {
            if (this.PermCheck(this.PlayerRank, 'buyvehicle')) {
                this.ShowBossPopup = 'buyvehicle'
                this.SelectedBuyVehicle = k
            }
        },

        BuyVehicleSection() {
            if (this.BuyVehicleInputs.Stock >= 1) {
                let category = ""
                if (this.BuyVehicleInputs.SelectedCategoryIndex >= 0) {
                    category = this.NewCategoryList[this.BuyVehicleInputs.SelectedCategoryIndex].name
                }
                postNUI('BuyVehicle', {
                    id: this.CurrentVehicleshop,
                    hash: this.AllVehicleData[this.SelectedBuyVehicle].name,
                    stock: this.BuyVehicleInputs.Stock,
                    price: this.BuyVehicleInputs.Price,
                    category: category,
                    carprice: this.AllVehicleData[this.SelectedBuyVehicle].price * this.BuyVehicleInputs.Stock
                })
            } else {
                this.ShowNotify('error', this.Language['dont_leave_empty'], 3000)
            }
        },

        CloseBuyVehicleSection() {
            this.ShowBossPopup = ''
            this.SelectedBuyVehicle = -1
            this.BuyVehicleInputs = {
                Stock: 1,
                Price: '',
                SelectedCategoryIndex: -1
            }
        },

        // Close Bossmenu Popup
        CloseBossPopup(type) {
            if (type == 'createcategory') {
                this.ShowBossPopup = ''
                this.Inputs.CategoryNameInput = ''
                this.Inputs.CategoryLabelInput = ''
            } else if (type == 'editcategory') {
                this.ShowBossPopup = ''
                this.Inputs.CategoryLabelInput = ''
                this.SelectedEditCategoryName = null
            } else if (type == 'editvehicle') {
                this.CloseEditVehicleScreen()
            } else if (type == 'buyvehicle') {
                this.CloseBuyVehicleSection()
            } else if (type == 'createperm') {
                this.ShowBossPopup = ''
                this.Inputs.PermNameInput = ''
                this.Inputs.PermLabelInput = ''
            }
        },

        // Buy vehicleshop & Transfer Req
        TransferReqFunction() {
            if (this.TransferReqFunctions == 'buycompany') {
                postNUI('BuyCompany', {
                    id: this.CurrentVehicleshop,
                    price: this.TransferReqCompanyPrice,
                })
            } else if (this.TransferReqFunctions == 'transferreq') {
                postNUI('AcceptedTransferReq', {
                    id: this.CurrentVehicleshop,
                    price: this.TransferReqCompanyPrice,
                    sender: this.TransferReqSender,
                    target: this.TransferReqTarget
                })
            }
        },

        CloseTransferReq() {
            if (this.TransferReqFunctions == 'buycompany') {
                this.ShowPopupToTarget = ''
                this.CurrentVehicleshop = -1
                this.TransferReqCompanyPrice = 0
                this.TransferReqCompanyName = ''
                this.TransferReqFunctions = ''
                postNUI('SetNuiFocus', false)
            } else if (this.TransferReqFunctions == 'transferreq') {
                postNUI('SendCancelTransferReqNotifyToSender', this.TransferReqSender)
                this.ShowPopupToTarget = ''
                this.CurrentVehicleshop = -1
                this.TransferReqCompanyPrice = 0
                this.TransferReqCompanyName = ''
                this.TransferReqFunctions = ''
                this.TransferReqTarget = null
                this.TransferReqSender = null
                postNUI('SetNuiFocus', false)
            }
        },

        // Deposit & Withdraw
        DepositMoney() {
            if (this.Inputs.DepositInput > 0) {
                postNUI('DepositMoney', {
                    id: this.CurrentVehicleshop,
                    value: this.Inputs.DepositInput
                })
                this.Inputs.DepositInput = ''
                this.ShowBossPopup = ''
            } else {
                this.ShowNotify('error', this.Language['dont_leave_empty'], 3000)
            }
        },

        WithdrawMoney() {
            if (this.Inputs.WithdrawInput > 0) {
                postNUI('WithdrawMoney', {
                    id: this.CurrentVehicleshop,
                    value: this.Inputs.WithdrawInput
                })
                this.Inputs.WithdrawInput = ''
                this.ShowBossPopup = ''
            } else {
                this.ShowNotify('error', this.Language['dont_leave_empty'], 3000)
            }
        },

        // Company Settings
        ChangeCompanyName() {
            if (this.Inputs.CompanyNameInput.length > 0) {
                if (this.PermCheck(this.PlayerRank, 'administration')) {
                    postNUI('ChangeCompanyName', {
                        id: this.CurrentVehicleshop,
                        value: this.Inputs.CompanyNameInput
                    })
                    this.Inputs.CompanyNameInput = ''
                    this.ShowNotify('success', this.Language['successfully_changed_company_name'], 3000)
                }
            } else {
                this.ShowNotify('error', this.Language['dont_leave_empty'], 3000)
            }
        },

        SendTransferRequest() {
            if (this.GetPermName(this.PlayerRank) && this.GetPermName(this.PlayerRank) == 'owner') {
                if (this.Inputs.TransferIdInput > 0) {
                    if (this.Inputs.TransferPriceInput > 0) {
                        postNUI('SendTransferRequest', {
                            id: this.CurrentVehicleshop,
                            targetid: this.Inputs.TransferIdInput,
                            price: this.Inputs.TransferPriceInput
                        })
                        this.Inputs.TransferIdInput = ''
                        this.Inputs.TransferPriceInput = ''
                    } else {
                        this.ShowNotify('error', this.Language['dont_leave_empty'], 3000)
                    }
                } else {
                    this.ShowNotify('error', this.Language['dont_leave_empty'], 3000)
                }
            }
        },

        MakeDiscount() {
            if (this.PermCheck(this.PlayerRank, 'discount')) {
                if (this.Inputs.DiscountInput > 0) {
                    if (this.Inputs.DiscountInput != this.Discount) {
                        postNUI('MakeDiscount', {
                            id: this.CurrentVehicleshop,
                            value: this.Inputs.DiscountInput
                        })
                        this.ShowNotify('success', this.Language['successfully_launched_discount'], 3000)
                    } else {
                        this.ShowNotify('error', this.Language['same_discount'], 3000)          
                    }
                } else {
                    this.ShowNotify('error', this.Language['dont_leave_empty'], 3000)
                }
            }
        },

        CancelDiscount() {
            if (this.PermCheck(this.PlayerRank, 'discount')) {
                if (this.Discount > 0) {
                    postNUI('CancelDiscount', this.CurrentVehicleshop)
                    this.Inputs.DiscountInput = ''
                    this.ShowNotify('information', this.Language['successfully_canceled_discount'], 3000)
                } else {
                    this.ShowNotify('error', this.Language['no_discount_campaign'], 3000)
                }
            }
        },

        DeleteAllLogs() {
            if (this.PermCheck(this.PlayerRank, 'removelog')) {
                postNUI('DeleteAllLogs', this.CurrentVehicleshop)
                this.ShowNotify('success', this.Language['successfully_deleted_logs'], 3000)
            }
        },

        SendBonusToStaff() {
            if (this.Inputs.BonusesInput > 0) {
                if (this.PermCheck(this.PlayerRank, 'bonus')) {
                    postNUI('SendBonusToStaff', {
                        id:  this.CurrentVehicleshop,
                        value: this.Inputs.BonusesInput
                    })
                    this.Inputs.BonusesInput = ''
                }
            } else {
                this.ShowNotify('error', this.Language['dont_leave_empty'], 3000)
            }
        },

        RaisePrices() {
            if (this.Inputs.RaiseInput > 0) {
                if (this.PermCheck(this.PlayerRank, 'raise')) {
                    postNUI('RaisePrices', {
                        id: this.CurrentVehicleshop,
                        value: this.Inputs.RaiseInput
                    })
                    this.Inputs.RaiseInput = ''
                    this.ShowNotify('success', this.Language['successfully_raised'], 3000)
                }
            } else {
                this.ShowNotify('error', this.Language['dont_leave_empty'], 3000)
            }
        },

        // Staff Settings
        SendJobRequest() {
            if (this.PermCheck(this.PlayerRank, 'hire')) {
                if (this.Inputs.EmployeeIdInput > 0) {
                    if (this.Inputs.EmployeeSalaryInput > 0) {
                        postNUI('SendJobRequest', {
                            id: this.CurrentVehicleshop,
                            targetid: this.Inputs.EmployeeIdInput,
                            salary: this.Inputs.EmployeeSalaryInput
                        })
                        this.Inputs.EmployeeIdInput = ''
                        this.Inputs.EmployeeSalaryInput = ''
                    } else {
                        this.ShowNotify('error', this.Language['dont_leave_empty'], 3000)
                    }
                } else {
                    this.ShowNotify('error', this.Language['dont_leave_empty'], 3000)
                }
            }
        },

        AcceptedJobRequest() {
            postNUI('AcceptedJobRequest', {
                id: this.CurrentVehicleshop,
                salary: this.JobReqSalary,
                sender: this.JobReqSender,
                target: this.JobReqTarget
            })
        },

        CloseJobReq(type) {
            if (type == 'reject') {
                postNUI('SendRejectedJobReqToSender', this.JobReqSender)
            }
            this.ShowPopupToTarget = ''
            this.CurrentVehicleshop = -1
            this.JobReqCompanyName = ''
            this.JobReqSalary = 0
            this.JobReqSender = null
            this.JobReqTarget = null
        },

        GiveSalaryPenalty() {
            if (this.PermCheck(this.PlayerRank, 'penalty')) {
                if (this.Inputs.SalaryPenaltyIdInput > 0) {
                    if (this.Inputs.SalaryPenaltyInput > 0) {
                        postNUI('GiveSalaryPenalty', {
                            id: this.CurrentVehicleshop,
                            targetid: this.Inputs.SalaryPenaltyIdInput,
                            penalty: this.Inputs.SalaryPenaltyInput
                        })
                        this.Inputs.SalaryPenaltyIdInput = ''
                        this.Inputs.SalaryPenaltyInput = ''
                    } else {
                        this.ShowNotify('error', this.Language['dont_leave_empty'], 3000)
                    }
                } else {
                    this.ShowNotify('error', this.Language['dont_leave_empty'], 3000)
                }
            }
        },

        EndThePunishment(identifier) {
            if (this.PermCheck(this.PlayerRank, 'penalty')) {
                if (identifier) {
                    postNUI('EndThePunishment', {
                        id: this.CurrentVehicleshop,
                        identifier: identifier
                    })
                }
            }
        },

        RankUpEmployee(identifier) {
            if (this.PermCheck(this.PlayerRank, 'rankchange')) {
                if (identifier) {
                    postNUI('RankUpEmployee', {
                        id: this.CurrentVehicleshop,
                        identifier: identifier
                    })
                }
            }
        },

        ReduceEmployeeRank(identifier) {
            if (this.PermCheck(this.PlayerRank, 'rankchange')) {
                if (identifier) {
                    postNUI('ReduceEmployeeRank', {
                        id: this.CurrentVehicleshop,
                        identifier: identifier
                    })
                }
            }
        },

        FireEmployee(identifier) {
            if (this.PermCheck(this.PlayerRank, 'fire')) {
                if (identifier) {
                    postNUI('FireEmployee', {
                        id: this.CurrentVehicleshop,
                        identifier: identifier
                    })
                }
            }
        },

        // Perm Functions
        PermCheck(name, action) {
            let Author = this.PermsTable.find(v => v.label == name)
            let Permission = Author.permissions.find(v => v.name == action)
            if (Permission.value) {
                return true
            } else {
                this.ShowNotify('error', this.Language['not_allowed'], 3000)
                return false
            }
        },

        GetPermName(label) {
            let Author = this.PermsTable.find(v => v.label == label)
            if (Author) {
                return Author.name
            } else {
                return null
            }
        },

        GetPermLabel(name) {
            let Author = this.PermsTable.find(v => v.name == name)
            if (Author) {
                return Author.label
            } else {
                return null
            }
        },

        // Camera angles
        HandleZoomScroll(event) {
            if (this.ShiftPressed) {
                if (event.deltaY < 0) {
                    postNUI('ZoomIn')
                } else {
                    postNUI('ZoomOut')
                }
            }
        },

        RotateCamera(event) {
            if (this.DraggingCheck) {
                if (!this.ShiftPressed) {
                    if (this.MouseX != null) {
                        if (event.clientX > this.MouseX) {
                            postNUI('RotateCameraRight')
                        } else if (event.clientX < this.MouseX) {
                            postNUI('RotateCameraLeft')
                        }
                    }
                }
                if (this.CameraAngle == 'interior' && this.ShiftPressed) {
                    if (this.MouseY != null) {
                        if (event.clientY > this.MouseY) {
                            postNUI('RotateCameraUp')
                        } else if (event.clientY < this.MouseY) {
                            postNUI('RotateCameraDown')
                        }
                    }
                }
                this.MouseX = event.clientX
                this.MouseY = event.clientY
            }
        },

        // Important Functions
        FilterNewCategoryForBoss() {
            this.NewCategoryList = []
            this.CategoryList.forEach(v => {
                if (v.name != 'all') {
                    this.NewCategoryList.push(v)
                }
            })
        },

        // CloseUI
        CloseUI(status) {
            this.Show = false
            this.MainPage = 'Normal'
            this.activePage = 'dashboard'
            this.HasOwner = false
            this.SelectedColor = null
            this.SelectedVehicleTable = {
                VehicleIndex: -1,
                VehicleHash: "",
                VehicleLabel: "",
                VehicleModel: "",
                VehiclePrice: 0,
                VehicleTopSpeed: 0,
                VehicleBraking: 0,
                VehicleAcceleration: 0,
                VehicleSuspension: 0,
                VehicleHandling: 0,
            }
            this.SelectedVehicleCategory = 'all'
            this.VehiclesTable = []
            this.Feedbacks = []
            this.CategoryList = []
            this.SearchInput = ""
            this.PlateInput = ""
            this.ShowPlateChange = false
            this.IsSearching = false
            this.ShowFeedback = false
            this.ShowPopupScrren = false
            this.ChangedPlate = false
            this.NormalPopupSettings = {
                Show: false,
                HeaderOne: '',
                HeaderTwo: '',
                Description: '',
                Function: null
            }
            this.FeedbackPopupSettings = {
                Show: false,
                Rating: null,
                Message: '',
            }
            this.ComplaintPopupSettings = {
                Show: false,
                Message: '',
            }
            this.ComplainTable = []
            this.EditVehicleInputs = {
                Name: '',
                Model: '',
                Img: '',
                Discount: '',
                Price: '',
            }
            this.SelectedEditCategoryName = null
            this.BuyVehicleInputs = {
                Stock: 1,
                Price: '',
                SelectedCategoryIndex: -1
            }
            this.ShiftPressed = false
            this.DraggingCheck = false
            this.MouseX = null
            this.MouseY = null
            this.CameraAngle = 'exterior'
            if (this.MainPage == 'Component' && this.activePage == 'preview') {
                this.LeavePreviewMode()
            }
            postNUI('CloseUI', status)
        },

        CloseBossmenu() {
            this.Show = false
            this.MainPage = 'Normal'
            this.activePage = 'dashboard'
            this.Inputs = {
                SoldVehiclesInput: '',
                CompanyNameInput: '',
                TransferIdInput: '',
                TransferPriceInput: '',
                DiscountInput: '',
                BonusesInput: '',
                RaiseInput: '',
                TransactionsInput: '',
                EmployeeIdInput: '',
                EmployeeSalaryInput: '',
                SalaryPenaltyIdInput: '',
                SalaryPenaltyInput: '',
                PenaltySearchInput: '',
                EmployeesInput: '',
                DepositInput: '',
                WithdrawInput: '',
                PermNameInput: '',
                PermLabelInput: '',
            }
            this.SelectedBossmenuCategory = 0
            this.SelectedEditCategoryName = null
            this.VehiclesTable = []
            this.Feedbacks = []
            this.CategoryList = []
            this.CompanyMoney = 0
            this.Preorders = []
            this.EmployeesTable = []
            this.SoldVehiclesLog = []
            this.Transactions = []
            this.PermsTable = []
            this.CompanyMoney = 0
            this.SelectedPerm = -1
            this.OriginalPermsTable = null
            this.BossmenuPageSettings = {
                PreorderPage: 1,
                SoldVehiclesPage: 1,
                TransactionsPage: 1,
                EmployeeWithPenaltyPage: 1,
                EmployeesPage: 1,
            }
            this.FeedbackComplaintScreen = -1
            this.VehicleEditScreen = -1
            this.CurrentVehicleshop = -1
            this.NotifySettings = {
                Show: false,
                Type: '',
                Message: '',
                Time: 0,
            }
            this.ComplainTable = []
            this.EditVehicleInputs = {
                Name: '',
                Model: '',
                Img: '',
                Discount: '',
                Price: '',
            }
            this.SelectedShowCategory = 0
            this.BuyVehicleInputs = {
                Stock: 1,
                Price: '',
                SelectedCategoryIndex: -1
            }
            postNUI('CloseBossmenu')
        },

        // Events
        HandleKeyDown(event) {
            if (event.key === 'Shift') {
                this.ShiftPressed = true
            }
        },

        HandleKeyUp(event) {
            if (event.key === 'Shift') {
                this.ShiftPressed = false
            }
        },

        LeftClickCheck(event) {
            if (event.button === 0) {
                this.DraggingCheck = true
                this.MouseX = event.clientX
                this.MouseY = event.clientY
            }
        },

        LeaveLeftClick(event) {
            if (event.button === 0) {
                this.DraggingCheck = false
            }
        },

        // Important Functions
        DiscountedPriceWithValue(vprice) {
            let price = vprice
      
            if (this.Discount > 0) {
              return price - (price * this.Discount / 100)
            } else if (this.SelectedVehicleTable.VehicleDiscount > 0) {
              return price - (price * this.SelectedVehicleTable.VehicleDiscount / 100)
            } else {
              return price
            }
        },

        DiscountPriceWithValue2(v, vprice) {
            let price = vprice
      

            if (v > 0) {
                return price - (price * v / 100)
            } else {
                return price
            }
        },

        AverageRating2() {
            if (this.Feedbacks.length == 0) {
                return 0;
            }
        
            const rating = this.Feedbacks.reduce((k, v) => k + v.stars, 0);
            return parseFloat((rating / this.Feedbacks.length).toFixed(1));
        },   
    },  
    
    computed: {
        FilterVehicles() {
            let x = this.VehiclesTable

            if (this.SelectedVehicleCategory !== 'all') {
                x = x.filter(v => v.category == this.SelectedVehicleCategory)
            }

            if (this.IsSearching && this.SearchInput != '') {
                return x.filter(v => v.name.toLowerCase().includes(this.SearchInput.toLowerCase()) || v.label.toLowerCase().includes(this.SearchInput.toLowerCase()) || v.model.toLowerCase().includes(this.SearchInput.toLowerCase()))
            }

            return x
        },

        BossMenuFilterVehicles() {
            let x = this.VehiclesTable

            if (this.IsSearching && this.SearchInput != '') {
                return x.filter(v => v.name.toLowerCase().includes(this.SearchInput.toLowerCase()) && v.stock > 0 || v.label.toLowerCase().includes(this.SearchInput.toLowerCase()) && v.stock > 0 || v.model.toLowerCase().includes(this.SearchInput.toLowerCase()) && v.stock > 0)
            } else {
                return x.filter(v => v.stock > 0)
            }
        },

        NotifyColor() {
            switch (this.NotifySettings.Type) {
                case 'success':
                  return '#00F0FF';
                case 'information':
                  return '#00FFB7';
                case 'error':
                  return '#FF0004';
                default:
                  return '';
            }
        },

        AvailableVehiclesCount() {
            return this.VehiclesTable.filter(v => v.stock > 0).length;
        },

        AverageRating() {
            if (this.Feedbacks.length == 0) {
                return 0;
            }

            const rating = this.Feedbacks.reduce((k, v) => k + v.stars, 0);
            return (rating / this.Feedbacks.length).toFixed(1);
        },     

        PreordersPage() {
            const s = (this.BossmenuPageSettings.PreorderPage - 1) * 7
            const e = s + 7
            return this.Preorders.slice(s, e)
        },

        FilterSoldVehiclesPage() {
            if (!this.Inputs.SoldVehiclesInput) {
                return this.SoldVehiclesLog
            } 
            return this.SoldVehiclesLog.filter(v => {
                return (
                    v.buyer.toLowerCase().includes(this.Inputs.SoldVehiclesInput.toLowerCase()) ||
                    v.vehicle.toLowerCase().includes(this.Inputs.SoldVehiclesInput.toLowerCase()) ||
                    v.price.toString().includes(this.Inputs.SoldVehiclesInput)
                )
            })
        },

        SoldVehiclesPage() {
            const s = (this.BossmenuPageSettings.SoldVehiclesPage - 1) * 7
            const e = s + 7
            return this.FilterSoldVehiclesPage.slice(s, e)
        },

        FilterTransactionsPage() {
            if (!this.Inputs.TransactionsInput) {
                return this.Transactions
            }

            const input = this.Inputs.TransactionsInput.toLowerCase();

            return this.Transactions.filter(v => {
                if (input === 'withdraw' || input === 'deposit') {
                    return v.type.toLowerCase() === input;
                }
                return (
                    v.name.toLowerCase().includes(input) ||
                    v.amount.toString().includes(this.Inputs.TransactionsInput)
                );
            });
        },

        TransactionsPage() {
            const s = (this.BossmenuPageSettings.TransactionsPage - 1) * 8
            const e = s + 8
            return this.FilterTransactionsPage.slice(s, e)
        },

        FilterEmployeesWithPenaltyTable() {
            if (!this.Inputs.PenaltySearchInput) {
                return this.EmployeesTable.filter(v => v.salarypenalty > 0);
            }

            const input = this.Inputs.PenaltySearchInput.toLowerCase();

            return this.EmployeesTable.filter(v => {
                return (
                    v.name.toLowerCase().includes(input) &&
                    v.salarypenalty > 0 ||
                    v.identifier.toLowerCase().includes(input) &&
                    v.salarypenalty > 0 ||
                    v.salary.toString().includes(this.Inputs.PenaltySearchInput) &&
                    v.salarypenalty > 0
                );
            });
        },

        EmployeeWithPenaltyPage() {
            const s = (this.BossmenuPageSettings.EmployeeWithPenaltyPage - 1) * 1
            const e = s + 1
            return this.FilterEmployeesWithPenaltyTable.slice(s, e)
        },

        FilterEmployeesTable() {
            if (!this.Inputs.EmployeesInput) {
                return this.EmployeesTable.filter(v => v.rank != 'owner')
            }

            const input = this.Inputs.EmployeesInput.toLowerCase();

            return this.EmployeesTable.filter(v => {
                return (
                    v.name.toLowerCase().includes(input) && v.rank != 'owner' ||
                    v.identifier.toLowerCase().includes(input) && v.rank != 'owner' ||
                    v.salary.toString().includes(this.Inputs.EmployeesInput) && v.rank != 'owner'
                );
            });
        },

        EmployeesPage() {
            const s = (this.BossmenuPageSettings.EmployeesPage - 1) * 8
            const e = s + 8
            return this.FilterEmployeesTable.slice(s, e)
        },

        FeedbackAndComplaintsTable() {
            const complaints = this.ComplainTable.map(item => ({
              ...item,
              type: 'complaint'
            }));
      
            const feedbacks = this.Feedbacks.map(item => ({
              ...item,
              type: 'feedback'
            }));
      
            return [...complaints, ...feedbacks];
        },

        TotalProfit() {
            let total = 0
      
            this.SoldVehiclesLog.forEach(v => {
              total += v.price
            })
      
            this.Transactions.forEach(v => {
                if (v.type === 'deposit') {
                  total += v.amount
                }
            })
      
            return total
        },

        TotalPayout() {
            let total = 0
            this.Transactions.forEach(v => {
                if (v.type === 'withdraw') {
                  total += v.amount
                }
            })
      
            return total
        },

        DiscountedPrice() {
            let price = this.SelectedVehicleTable.VehiclePrice
      
            if (this.Discount > 0) {
              return price - (price * this.Discount / 100)
            } else if (this.SelectedVehicleTable.VehicleDiscount > 0) {
              return price - (price * this.SelectedVehicleTable.VehicleDiscount / 100)
            } else {
              return price
            }
        },
    },

    watch: {
        'Inputs.SoldVehiclesInput'() {
            this.BossmenuPageSettings.SoldVehiclesPage = 1;
        },

        'Inputs.TransactionsInput'() {
            this.BossmenuPageSettings.TransactionsPage = 1;
        },

        'Inputs.PenaltySearchInput'() {
            this.BossmenuPageSettings.EmployeeWithPenaltyPage = 1;
        },

        'Inputs.EmployeesPage'() {
            this.BossmenuPageSettings.EmployeesPage = 1;
        }
    },

    beforeDestroy() {
        window.removeEventListener('keydown', this.HandleKeyDown);
        window.removeEventListener('keyup', this.HandleKeyUp);
    },
    
    mounted() {
        window.addEventListener("message", event => {
            const data = event.data;
            switch (data.action) {
                case 'Setup':
                    this.Language = data.language
                    this.ColorsTable = data.colorstable
                    this.BossmenuCategory = data.bossmenucategories
                    this.CheckProfanities = data.checkprofanities
                    this.Profanities = data.profanities
                    this.FeedbackCharacters = data.feedbackcharacters
                    this.ComplaintCharacters = data.complaintcharacters
                    this.TestDrivePrice = data.testdriveprice
                    this.AllowPlateChange = data.platechange
                    this.PlateChangePrice = data.platechangeprice
                    break;
                case 'OpenVehicleshop':
                    this.Show = true
                    this.MainPage = 'Normal'
                    this.HasOwner = data.hasowner
                    this.AllVehicleData = data.allvehiclestable
                    this.PlayerName = data.playername
                    this.PlayerMoney = data.playermoney
                    this.PlayerPfp = data.playerpfp
                    this.CurrentVehicleshop = data.vehicleshop
                    this.VehicleShopName = data.vehicleshopname
                    this.VehicleshopDescription = data.vehicleshopdescription
                    this.VehiclesTable = data.vehicles
                    this.CategoryList = data.categories
                    this.Feedbacks = data.feedbacks
                    this.Discount = data.discount
                    this.VehicleShopStar = this.AverageRating2()
                    break;
                case 'UpdateCreateSelectedVehicle':
                    this.SelectedVehicleTable.VehicleTopSpeed = data.speed
                    this.SelectedVehicleTable.VehicleBraking = data.brake
                    this.SelectedVehicleTable.VehicleAcceleration = data.acceleration
                    this.SelectedVehicleTable.VehicleSuspension = data.suspension
                    this.SelectedVehicleTable.VehicleHandling = data.handling
                    this.PlateInput = data.plate
                    this.CurrentVehicleColor = data.color
                    break;
                case 'ChangeCurrentVehicleColorStatus':
                    this.CurrentVehicleColor = data.color
                    break;
                case 'UpdatePlateInput':
                    this.PlateInput = data.value
                    break;
                case 'ShowTestDriveTime':
                    if (!this.ShowTestDriveTime) {
                        this.ShowTestDriveTime = true
                    }
                    this.TestDriveTime = data.time
                    break;
                case 'CloseTimer':
                    this.ShowTestDriveTime = false
                    this.TestDriveTime = 0
                    break;
                case 'ChangePlateAccepted':
                    postNUI('ChangePlate', this.PlateInput)
                    this.ShowPlateChange = false
                    this.ShowNotify('success', this.Language['successfully_changed_plate'], 2000)
                    this.ChangedPlate = true
                    setTimeout(() => {
                        postNUI('ResetCameraToNormal')
                    }, 1500)
                    break;
                case 'BuyCompany':
                    this.ShowPopupToTarget = 'TransferRequest'
                    this.CurrentVehicleshop = data.vehicleshop
                    this.TransferReqCompanyPrice = data.price
                    this.TransferReqCompanyName = data.name
                    this.TransferReqFunctions = 'buycompany'
                    break;
                case 'CloseTransferReq':
                    this.CloseTransferReq()
                    break;
                case 'OpenBossmenu':
                    this.Show = true
                    this.MainPage = 'Bossmenu'
                    this.activePage = 'dashboard'
                    this.AllVehicleData = data.allvehiclestable
                    this.CurrentVehicleshop = data.vehicleshop
                    this.PlayerName = data.playername
                    this.PlayerMoney = data.playermoney
                    this.PlayerPfp = data.playerpfp
                    this.PlayerRank = data.playerrank
                    this.VehicleShopName = data.vehicleshopname
                    this.VehicleshopDescription = data.vehicleshopdescription
                    this.CompanyMoney = data.companymoney
                    this.Feedbacks = data.feedbacks
                    this.EmployeesTable = data.employees
                    this.VehiclesTable = data.vehicles
                    this.SoldVehiclesLog = data.vehiclessold
                    this.Preorders = data.preorders
                    this.Transactions = data.transactions
                    this.PermsTable = data.perms
                    this.Discount = data.discount
                    this.CategoryList = data.categories
                    this.ComplainTable = data.complaints
                    this.FilterNewCategoryForBoss()
                    if (this.Discount > 0) {
                        this.Inputs.DiscountInput = data.discount
                    }
                    break;
                case 'UpdateUI':
                    this.PlayerMoney = data.playermoney
                    this.PlayerRank = data.playerrank
                    this.VehicleShopName = data.vehicleshopname
                    this.CompanyMoney = data.companymoney
                    this.Feedbacks = data.feedbacks
                    this.EmployeesTable = data.employees
                    this.VehiclesTable = data.vehicles
                    this.SoldVehiclesLog = data.vehiclessold
                    this.Preorders = data.preorders
                    this.Transactions = data.transactions
                    this.PermsTable = data.perms
                    this.Discount = data.discount
                    this.CategoryList = data.categories
                    this.ComplainTable = data.complaints
                    this.Inputs.DiscountInput = data.discount
                    this.FilterNewCategoryForBoss()
                    break;
                case 'SendTransferRequest':
                    this.ShowPopupToTarget = 'TransferRequest'
                    this.CurrentVehicleshop = data.vehicleshop
                    this.TransferReqCompanyPrice = data.price
                    this.TransferReqCompanyName = data.name
                    this.TransferReqSender = data.sender
                    this.TransferReqTarget = data.target
                    this.TransferReqFunctions = 'transferreq'
                    break;
                case 'SendJobRequest':
                    this.ShowPopupToTarget = 'JobReq'
                    this.CurrentVehicleshop = data.vehicleshop
                    this.JobReqCompanyName = data.name
                    this.JobReqSalary = data.salary
                    this.JobReqSender = data.sender
                    this.JobReqTarget = data.target
                    break;
                case 'OpenComplaintForm':
                    this.CurrentVehicleshop = data.vehicleshop
                    this.ComplaintPopupSettings.Show = true
                    break;
                case 'ShowFeedbackScreen':
                    this.CurrentVehicleshop = data.id
                    this.FeedbackPopupSettings.Show = true
                    break;
                case 'CloseJobReq':
                    this.CloseJobReq('normal')
                    break;
                case 'CloseBossmenu':
                    this.CloseBossmenu()
                    break;
                case 'CloseBossPopup':
                    this.CloseBossPopup(data.type)
                    break;
                case 'ShowNotify':
                    this.ShowNotify(data.type, data.text, data.ms)
                    break;
                case 'CloseUI':
                    this.CloseUI(data.status)
                    break;
                default:
                    break;
            }
        });
        
        window.addEventListener('keydown', (event) => {
            if (event.key == 'Escape') {
                if (this.ComplaintPopupSettings.Show || this.FeedbackPopupSettings.Show) {
                    this.CloseComplaintAndFeedback()
                }
                if (this.Show && this.MainPage != 'Bossmenu' && this.activePage != 'preview' && this.activePage != 'companystaffsettings' && this.activePage != 'companysettings' && this.activePage != 'buyvehicle' && !this.ShowPopupScrren && !this.ShowBossPopup && !this.ShowPlateChange && !this.ShowColorPicker) {
                    this.CloseUI(true)
                }
                if (this.Show && this.MainPage == 'Bossmenu' && this.activePage != 'companystaffsettings' && this.activePage != 'companysettings' && this.activePage != 'buyvehicle' && !this.ShowBossPopup) {
                    this.CloseBossmenu()
                }
                if (this.activePage == 'preview') {
                    this.LeavePreviewMode()
                }
                if (this.activePage == 'companystaffsettings' || this.activePage == 'companysettings') {
                    this.setActivePage('company')
                    this.Inputs.CompanyNameInput = ''
                    this.Inputs.TransferIdInput = ''
                    this.Inputs.CompanyNameInput = ''
                    this.Inputs.TransferIdInput = ''
                    this.Inputs.TransferPriceInput = ''
                    this.Inputs.DiscountInput = ''
                    this.Inputs.BonusesInput = ''
                    this.Inputs.RaiseInput = ''
                    this.Inputs.EmployeeIdInput = ''
                    this.Inputs.EmployeeSalaryInput = ''
                    this.Inputs.SalaryPenaltyIdInput = ''
                    this.Inputs.SalaryPenaltyInput = ''
                    this.Inputs.PenaltySearchInput = ''
                    this.Inputs.EmployeesInput = ''
                }
                if (this.ShowPlateChange) {
                    this.ShowPlateChange = false
                    postNUI('ResetCameraToNormal')
                }
                if (this.ShowColorPicker) {
                    this.ShowColorPicker = false
                    this.SelectedColor = null
                    this.ColorPickerColor = "#FFF"
                }
                if (this.activePage == 'buyvehicle' && !this.ShowBossPopup) {
                    this.setActivePage('vehicles')
                }
            } else if (event.key == 'Shift') {
                this.ShiftPressed = true
            }
        });

        window.addEventListener('keyup', this.HandleKeyUp);
    },
});

app.component('inlinesvg', inlinesvg);
app.use(store).mount("#app");

const resourceName = window.GetParentResourceName ? window.GetParentResourceName() : "real-vehicleshop";

window.postNUI = async (name, data) => {
    try {
        const response = await fetch(`https://${resourceName}/${name}`, {
            method: "POST",
            mode: "cors",
            cache: "no-cache",
            credentials: "same-origin",
            headers: {
                "Content-Type": "application/json"
            },
            redirect: "follow",
            referrerPolicy: "no-referrer",
            body: JSON.stringify(data)
        });
        return !response.ok ? null : response.json();
    } catch (error) {
        // console.log(error)
    }
};

let audioPlayer = null;
function SoundPlayer(val) {
    let audioPath = `./sounds/${val}`;
    audioPlayer = new Howl({
        src: [audioPath]
    });
    audioPlayer.volume(0.5);
    audioPlayer.play();
}