{-# LANGUAGE LambdaCase #-}

{-# OPTIONS_HADDOCK hide #-}
{-# OPTIONS_GHC -fno-warn-deprecations #-}

module Options.Applicative.Discrimination
    (
    -- * Type (re-export from Cardano.Address)
      NetworkTag(..)

    -- * Applicative Parser
    , networkTagOpt
    ) where

import Prelude

import Cardano.Address
    ( NetworkTag (..) )
import Options.Applicative
    ( Parser
    , completer
    , eitherReader
    , helpDoc
    , listCompleter
    , long
    , metavar
    , option
    )
import Options.Applicative.Help.Pretty
    ( string, vsep )
import Options.Applicative.Style
    ( Style (..) )
import Text.Read
    ( readMaybe )

import qualified Cardano.Address.Style.Byron as Byron
import qualified Cardano.Address.Style.Jormungandr as Jormungandr
import qualified Cardano.Address.Style.Shelley as Shelley

--
-- Applicative Parser
--

-- | Parse a 'NetworkTag' from the command-line, as an option
networkTagOpt :: Style -> Parser NetworkTag
networkTagOpt style = option (eitherReader reader) $ mempty
    <> metavar "NETWORK-TAG"
    <> long "network-tag"
    <> helpDoc  (Just (vsep (string <$> doc style)))
    <> completer (listCompleter $ show <$> tagsFor style)
  where
    doc style' =
        [ "A tag which identifies a Cardano network."
        , ""
        ] ++ case style' of
        Byron ->
            [ "┌ Byron / Icarus ──────────"
            , "│ mainnet: " <> show (unNetworkTag (snd Byron.byronMainnet))
            , "│ staging: " <> show (unNetworkTag (snd Byron.byronStaging))
            , "│ testnet: " <> show (unNetworkTag (snd Byron.byronTestnet))
            ]
        Icarus ->
            doc Byron
        Jormungandr ->
            [ "┌ Jormungandr ─────────────"
            , "│ testnet: " <> show (unNetworkTag Jormungandr.incentivizedTestnet)
            ]
        Shelley ->
            [ "┌ Shelley ─────────────────"
            , "│ mainnet: " <> show (unNetworkTag Shelley.shelleyMainnet)
            , "│ testnet: " <> show (unNetworkTag Shelley.shelleyTestnet)
            ]

    tagsFor = \case
        Byron ->
            [ unNetworkTag (snd Byron.byronMainnet)
            , unNetworkTag (snd Byron.byronStaging)
            , unNetworkTag (snd Byron.byronTestnet)
            ]
        Icarus ->
            tagsFor Byron
        Jormungandr ->
            [ unNetworkTag Jormungandr.incentivizedTestnet
            ]
        Shelley ->
            [ unNetworkTag Shelley.shelleyMainnet
            , unNetworkTag Shelley.shelleyTestnet
            ]

    reader =
        maybe
            (Left "Invalid network tag. Must be a integer value.")
            (Right . NetworkTag)
            . readMaybe
