require 'test_helper'

class DummyPxeLoader
  include PxeLoaderSupport
end

class PxeLoaderSupportTest < ActiveSupport::TestCase
  def setup
    @subject = DummyPxeLoader.new
    @host = FactoryBot.create(:host)
    @subject.stubs(:template_kinds).returns(Operatingsystem.new.template_kinds)
  end

  describe "template kind" do
    test "is not found when PXE loader is not set" do
      @host.pxe_loader = ""
      assert_nil @subject.pxe_loader_kind(@host)
    end

    test "is not found when PXE loader is set to None" do
      @host.pxe_loader = "None"
      assert_nil @subject.pxe_loader_kind(@host)
    end

    test "PXELinux is found for given filename" do
      @host.pxe_loader = "pxelinux.0"
      assert_equal :PXELinux, @subject.pxe_loader_kind(@host)
    end

    test "PXEGrub is found for given filename" do
      @host.pxe_loader = "grub/grubx64.efi"
      assert_equal :PXEGrub, @subject.pxe_loader_kind(@host)
    end

    test "PXEGrub2 is found for given filename" do
      @host.pxe_loader = "grub2/grubx64.efi"
      assert_equal :PXEGrub2, @subject.pxe_loader_kind(@host)
    end

    test "PXEGrub2 is found for shimx64.efi filename" do
      @host.pxe_loader = "grub2/shimx64.efi"
      assert_equal :PXEGrub2, @subject.pxe_loader_kind(@host)
    end

    test "PXEGrub2 is found for shimia32.efi filename" do
      @host.pxe_loader = "grub2/shimia32.efi"
      assert_equal :PXEGrub2, @subject.pxe_loader_kind(@host)
    end

    test "PXELinux is found for given loader name" do
      @host.pxe_loader = "PXELinux UEFI"
      assert_equal :PXELinux, @subject.pxe_loader_kind(@host)
    end

    test "PXEGrub is found for given loader name" do
      @host.pxe_loader = "Grub UEFI"
      assert_equal :PXEGrub, @subject.pxe_loader_kind(@host)
    end

    test "PXEGrub2 is found for given loader name" do
      @host.pxe_loader = "Grub2 UEFI"
      assert_equal :PXEGrub2, @subject.pxe_loader_kind(@host)
    end
  end

  describe "preferred loader" do
    setup do
      @template_pxelinux = FactoryBot.create(:provisioning_template, :template_kind => TemplateKind.find_by_name(:PXELinux))
      @template_pxegrub = FactoryBot.create(:provisioning_template, :template_kind => TemplateKind.find_by_name(:PXEGrub))
      @template_pxegrub2 = FactoryBot.create(:provisioning_template, :template_kind => TemplateKind.find_by_name(:PXEGrub2))
    end

    test "is none for zero template kinds and templates" do
      @subject.expects(:template_kinds).returns([])
      @subject.expects(:os_default_templates).returns([])
      assert_nil @subject.preferred_loader
    end

    test "is none for zero templates" do
      @subject.expects(:os_default_templates).returns([])
      assert_nil @subject.preferred_loader
    end

    test "is none for zero template kinds" do
      @subject.expects(:template_kinds).returns([])
      @subject.expects(:os_default_templates).returns([@template_pxelinux, @template_pxegrub, @template_pxegrub2])
      assert_nil @subject.preferred_loader
    end

    test "is PXEGrub2 for associated templates" do
      @subject.expects(:os_default_templates).returns([@template_pxelinux, @template_pxegrub, @template_pxegrub2])
      assert_equal "Grub2 UEFI", @subject.preferred_loader
    end

    test "is PXELinux for associated templates" do
      @subject.expects(:os_default_templates).returns([@template_pxelinux, @template_pxegrub])
      assert_equal "PXELinux BIOS", @subject.preferred_loader
    end

    test "is PXEGrub for associated templates" do
      @subject.expects(:os_default_templates).returns([@template_pxegrub])
      assert_equal "Grub UEFI", @subject.preferred_loader
    end
  end

  describe 'firmware_type' do
    test 'detects none firmware' do
      assert_equal :none, DummyPxeLoader.firmware_type('None')
    end

    test 'detects bios firmware' do
      assert_equal :bios, DummyPxeLoader.firmware_type('PXELinux BIOS')
    end

    test 'detects uefi firmware' do
      assert_equal :uefi, DummyPxeLoader.firmware_type('Grub2 UEFI')
    end

    test 'defaults to bios firmware' do
      assert_equal :bios, DummyPxeLoader.firmware_type('Anything')
    end
  end
end
