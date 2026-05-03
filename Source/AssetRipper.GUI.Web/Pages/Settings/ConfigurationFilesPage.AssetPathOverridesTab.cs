using AssetRipper.Import.Configuration;
using AssetRipper.GUI.Web.Paths;

namespace AssetRipper.GUI.Web.Pages.Settings;

public sealed partial class ConfigurationFilesPage
{
	private sealed class AssetPathOverridesTab : DataStorageTab
	{
		public static AssetPathOverridesTab Instance { get; } = new();

		public override string DisplayName => "Asset Path Overrides";

		protected override IEnumerable<HtmlTab> GetTabs()
		{
			yield return new OverridesTab();
		}

		private sealed class OverridesTab : HtmlTab
		{
			public override string DisplayName => "AssetPathOverrideList";

			public override void Write(TextWriter writer)
			{
				AssetPathOverrideList? overrides = GameFileLoader.Settings.SingletonData.TryGetStoredValue(nameof(AssetPathOverrideList), out AssetPathOverrideList? list)
					? list
					: null;

				if (overrides is null or { Count: 0 })
				{
					using (new Div(writer).WithTextCenter().End())
					{
						new P(writer).WithClass("p-2").Close("No asset path overrides have been loaded.");
						using (new Form(writer).WithAction("/ConfigurationFiles/AssetPathOverrides/Add").WithMethod("post").End())
						{
							new Input(writer).WithType("submit").WithClass("btn btn-primary mx-1").WithValue(Localization.Load.ToHtml()).Close();
						}
					}
				}
				else
				{
					new P(writer).WithClass("p-2").Close($"Loaded {overrides.Count} override(s).");
					using (new Div(writer).WithClass("text-center").End())
					{
						using (new Form(writer).WithAction("/ConfigurationFiles/AssetPathOverrides/Add").WithMethod("post").End())
						{
							new Input(writer).WithType("submit").WithClass("btn btn-primary mx-1").WithValue("Replace".ToHtml()).Close();
						}
						using (new Form(writer).WithAction("/ConfigurationFiles/AssetPathOverrides/Remove").WithMethod("post").End())
						{
							new Input(writer).WithType("submit").WithClass("btn btn-danger mx-1").WithValue("Remove".ToHtml()).Close();
						}
					}
				}
			}
		}
	}
}
