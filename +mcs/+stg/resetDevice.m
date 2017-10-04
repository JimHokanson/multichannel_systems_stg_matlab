function resetDevice()
    error('Not yet implemented')
        CMcsUsbFactoryNet fn = new CMcsUsbFactoryNet();
        fn.Connect((CMcsUsbListEntryNet)cbDeviceList.SelectedItem);
        fn.Coldstart(CFirmwareDestinationNet.DSP);
        fn.Coldstart(CFirmwareDestinationNet.USB);
        fn.Disconnect();
end