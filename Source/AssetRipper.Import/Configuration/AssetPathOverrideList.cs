using System.Text.Json.Serialization;

namespace AssetRipper.Import.Configuration;

public class AssetPathOverrideList : List<AssetPathOverride> { }

[JsonSourceGenerationOptions(WriteIndented = true)]
[JsonSerializable(typeof(AssetPathOverrideList))]
public partial class AssetPathOverrideListContext : JsonSerializerContext
{
}
