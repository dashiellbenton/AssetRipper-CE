using AssetRipper.Assets;
using AssetRipper.Import.Configuration;

namespace AssetRipper.Processing;

public sealed class AssetPathOverrideProcessor : IAssetProcessor
{
	private readonly AssetPathOverrideList overrides;

	public AssetPathOverrideProcessor(AssetPathOverrideList overrides)
	{
		this.overrides = overrides;
	}

	public void Process(GameData gameData)
	{
		if (overrides.Count == 0)
		{
			return;
		}

		Dictionary<long, AssetPathOverride> overrideDict = [];
		foreach (AssetPathOverride op in overrides)
		{
			overrideDict[op.PathID] = op;
		}

		foreach (IUnityObjectBase asset in gameData.GameBundle.FetchAssets())
		{
			if (overrideDict.TryGetValue(asset.PathID, out AssetPathOverride? op))
			{
				if (op.OverridePath is not null)
				{
					asset.OverridePath = op.OverridePath;
				}
				if (op.OverrideDirectory is not null)
				{
					asset.OverrideDirectory = op.OverrideDirectory;
				}
				if (op.OverrideName is not null)
				{
					asset.OverrideName = op.OverrideName;
				}
				if (op.OverrideExtension is not null)
				{
					asset.OverrideExtension = op.OverrideExtension;
				}
			}
		}
	}
}
